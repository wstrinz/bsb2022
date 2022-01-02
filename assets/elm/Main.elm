module Main exposing (..)

import Browser
import Html exposing (Html, a, article, div, node, p, span, text)
import Html.Attributes as Attr exposing (attribute, class)
import Html.Events exposing (onClick)
import Html.Keyed as Keyed
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Maybe exposing (Maybe(..))
import RemoteData exposing (RemoteData(..), WebData)
import RemoteData.Http


main : Program Flags Model Msg
main =
    Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


type alias Story =
    { title : String
    , author : Maybe String
    , content : String
    , description : Maybe String
    , link : String
    , id : Int
    , read : Bool
    }


type alias Model =
    { counter : Int
    , showNav : Bool
    , stories : WebData (List Story)
    }


initialStories : List Story
initialStories =
    [ { title = "The story of the day"
      , author = Just "The author"
      , content = "The content"
      , description = Just "The description"
      , link = "http://example.com"
      , id = 1
      , read = False
      }
    ]


type alias Flags =
    {}


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { counter = 0
      , showNav = False
      , stories = NotAsked
      }
    , RemoteData.Http.get "/api/stories" FetchStoriesResponse storiesDecoder
    )


type Msg
    = Increment
    | Decrement
    | ToggleNav
    | FetchStories
    | FetchStoriesResponse (WebData (List Story))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( { model | counter = model.counter + 1 }
            , Cmd.none
            )

        Decrement ->
            ( { model | counter = model.counter - 1 }
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


storiesDecoder : Decoder (List Story)
storiesDecoder =
    Decode.list storyDecoder


storyDecoder : Decoder Story
storyDecoder =
    Decode.succeed Story
        |> required "title" Decode.string
        |> required "author" (Decode.nullable Decode.string)
        |> required "content" Decode.string
        |> required "description" (Decode.nullable Decode.string)
        |> required "link" Decode.string
        |> required "id" Decode.int
        |> required "read" Decode.bool


slot : String -> Html.Attribute Msg
slot slotName =
    Attr.attribute "slot" slotName


storyHeader : Story -> List (Html Msg)
storyHeader story =
    [ node "bubble-banner"
        [ slot "header-content" ]
        [ node "drip-illo"
            [ slot "bubble"
            , Attr.name "medium_audience"
            ]
            []
        , span
            [ slot "heading"
            ]
            [ text story.title ]
        , span
            [ slot "description"
            ]
            [ text (story.author |> Maybe.withDefault "") ]
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
    Keyed.node "div" [] [ ( String.fromInt story.id, node "htm-element" [ attribute "data-html" story.content ] [] ) ]


storyView : Story -> Html Msg
storyView story =
    node "roll-up-item"
        [ attribute "open" "true", attribute "clickable" "true" ]
        (storyHeader story
            ++ [ article [ slot "content" ]
                    [ storyContent story
                    , node "butt-on"
                        []
                        [ text "My Button" ]
                    ]
               ]
        )


storiesView : Model -> Html Msg
storiesView model =
    node "roll-up"
        []
        [ div
            [ Attr.attribute "slot" "roll-up-item-list"
            ]
            (List.map storyView <| RemoteData.withDefault initialStories model.stories)
        ]


bones : Model -> Html Msg
bones model =
    div [ Attr.id "grid", Attr.class "hide-right-sidebar" ]
        [ div [ Attr.id "left" ]
            [ div [ Attr.id "top-nav" ]
                [ a [ Attr.tabindex 1, Attr.title "Open Nav", onClick ToggleNav ]
                    [ node "drip-illo" [ Attr.size 36, Attr.name "Medium Audience" ] []
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
