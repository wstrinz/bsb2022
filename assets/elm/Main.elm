module Main exposing (..)

import Browser
import Html exposing (Html, a, article, div, node, p, span, text)
import Html.Attributes as Attr exposing (attribute, class)
import Html.Events exposing (onClick)
import Html.Keyed as Keyed
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Keyboard exposing (Key(..), RawKey(..))
import Maybe exposing (Maybe(..))
import Maybe.Extra
import RemoteData exposing (RemoteData(..), WebData)
import RemoteData.Http


main : Program Flags Model Msg
main =
    Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Keyboard.downs KeyDown
        , Keyboard.ups KeyUp
        ]


type alias Story =
    { title : String
    , author : Maybe String
    , content : Maybe String
    , description : Maybe String
    , link : String
    , id : Int
    , read : Bool
    }


type alias Model =
    { counter : Int
    , showNav : Bool
    , stories : WebData (List Story)
    , storyCursor : Int
    , pressedKeys : List Key
    }


type alias Flags =
    {}


initialStories : List Story
initialStories =
    [ { title = "The story of the day"
      , author = Just "The author"
      , content = Just "The content"
      , description = Just "The description"
      , link = "http://example.com"
      , id = 1
      , read = False
      }
    ]


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { counter = 0
      , showNav = False
      , stories = NotAsked
      , storyCursor = 0
      , pressedKeys = []
      }
    , RemoteData.Http.get "/api/stories" FetchStoriesResponse storiesDecoder
    )


type Msg
    = Increment
    | Decrement
    | ToggleNav
    | FetchStories
    | FetchStoriesResponse (WebData (List Story))
    | KeyDown RawKey
    | KeyUp RawKey


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( { model | storyCursor = model.storyCursor + 1 }
            , Cmd.none
            )

        Decrement ->
            ( { model | storyCursor = model.storyCursor - 1 }
            , Cmd.none
            )

        ToggleNav ->
            ( { model | showNav = not model.showNav }
            , Cmd.none
            )

        FetchStories ->
            ( { model | stories = Loading }
            , RemoteData.Http.get "/api/stories" FetchStoriesResponse storiesDecoder
            )

        FetchStoriesResponse response ->
            ( { model | stories = response }, Cmd.none )

        KeyDown keyMsg ->
            case Keyboard.anyKeyOriginal keyMsg of
                Just (Character "j") ->
                    ( { model | storyCursor = model.storyCursor + 1 }
                    , Cmd.none
                    )

                Just (Character "k") ->
                    ( { model | storyCursor = model.storyCursor - 1 }
                    , Cmd.none
                    )

                _ ->
                    ( model
                    , Cmd.none
                    )

        KeyUp _ ->
            ( model, Cmd.none )


storiesDecoder : Decoder (List Story)
storiesDecoder =
    Decode.list storyDecoder


storyDecoder : Decoder Story
storyDecoder =
    Decode.succeed Story
        |> required "title" Decode.string
        |> required "author" (Decode.nullable Decode.string)
        |> required "content" (Decode.nullable Decode.string)
        |> required "description" (Decode.nullable Decode.string)
        |> required "link" Decode.string
        |> required "id" Decode.int
        |> required "read" Decode.bool


slot : String -> Html.Attribute Msg
slot slotName =
    Attr.attribute "slot" slotName


storyDescription : Bool -> Story -> List (Html Msg)
storyDescription showDescription story =
    let
        preview =
            if showDescription then
                [ node "htm-element" [ attribute "data-html" (story.description |> Maybe.withDefault "" |> String.slice 0 350) ] [] ]

            else
                []
    in
    (Maybe.map (\a -> a ++ " - ") story.author |> Maybe.withDefault "" |> text)
        :: preview


storyHeader : Bool -> Story -> List (Html Msg)
storyHeader isOpen story =
    [ node "bubble-banner"
        [ slot "header-content" ]
        [ Html.img
            [ attribute "src" "https://www.rockpapershotgun.com/static/4a50b66f9c50455a1f1ff417b5ada51c/icon/favicon-32x32.png", slot "bubble" ]
            []
        , span
            [ slot "heading"
            , Attr.style "white-space" "normal"
            ]
            [ text story.title ]
        , span
            [ slot "description"
            ]
            (storyDescription (not isOpen) story)
        ]
    , node "butt-on"
        [ Attr.attribute "size" "medium"
        , Attr.type_ "tertiary"
        , Attr.attribute "slot" "header-toggle-open"
        , Attr.attribute "icon" "edit"
        , Attr.class "icon-button"
        ]
        [ text "Open" ]
    , node "butt-on"
        [ Attr.attribute "size" "medium"
        , Attr.type_ "tertiary"
        , Attr.attribute "slot" "header-toggle-close"
        ]
        [ text "Close" ]
    ]


storyContent : Story -> Html Msg
storyContent story =
    let
        content =
            Maybe.Extra.or story.content story.description |> Maybe.withDefault "<p>No content</p>"
    in
    Keyed.node "div" [] [ ( String.fromInt story.id, node "htm-element" [ attribute "data-html" content ] [] ) ]


storyView : Bool -> Story -> Html Msg
storyView isOpen story =
    let
        isOpenAttr =
            if isOpen then
                "true"

            else
                "false"
    in
    node "roll-up-item"
        [ attribute "open" isOpenAttr, attribute "clickable" "true" ]
        (storyHeader isOpen story
            ++ [ article [ slot "content" ]
                    [ storyContent story
                    ]
               ]
        )


storiesView : Model -> Html Msg
storiesView model =
    let
        currentStories stories =
            List.drop model.storyCursor stories

        indexedStoryView idx =
            storyView (idx == 0)
    in
    node "roll-up"
        []
        [ div
            [ Attr.attribute "slot" "roll-up-item-list"
            ]
            (RemoteData.withDefault initialStories model.stories
                |> currentStories
                |> List.indexedMap indexedStoryView
            )
        ]


bones : Model -> Html Msg
bones model =
    div [ Attr.id "grid", Attr.class "hide-right-sidebar" ]
        [ div [ Attr.id "left" ]
            [ div [ Attr.id "top-nav" ]
                [ a [ Attr.tabindex 2, Attr.title "Open Nav", onClick ToggleNav ]
                    [ node "drip-illo" [ attribute "size" "x-small", Attr.name "Settings" ] []
                    ]
                , a [ Attr.tabindex 1, Attr.title "Last", onClick Decrement ]
                    [ node "drip-illo" [ attribute "size" "x-small", Attr.name "Medium Audience" ] []
                    ]
                , a [ Attr.tabindex 2, Attr.title "Next", onClick Increment ]
                    [ node "drip-illo" [ attribute "size" "x-small", Attr.name "Party" ] []
                    ]
                ]
            , div [ Attr.id "sub-nav", Attr.classList [ ( "sub-nav", True ), ( "sub-nav--open", model.showNav ) ] ]
                [ span [ class "sidebar-toggle" ]
                    [ p [ class "pa-4" ] [ text "Close" ]
                    ]
                ]
            ]
        , div
            [ Attr.id "main" ]
            [ node "drip-bones"
                []
                [ storiesView model ]
            ]
        , div [ Attr.id "right", attribute "data-component" "right-sidebar" ] [ text "hi" ]
        ]


view : Model -> Html Msg
view model =
    bones model
