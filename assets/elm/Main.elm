module Main exposing (..)

import Browser
import Html exposing (Html, a, article, aside, button, div, figcaption, figure, h1, img, li, node, p, section, span, text, ul)
import Html.Attributes as Attr exposing (attribute, class, href)
import Html.Events exposing (onClick)


main : Program () Model Msg
main =
    Browser.sandbox { init = init, update = update, view = view }


type alias Story =
    { title : String
    , author : String
    , body : String
    , id : Int
    , read : Bool
    }


type alias Model =
    { counter : Int
    , showNav : Bool
    , stories : List Story
    }


initialStories : List Story
initialStories =
    [ { title = "React"
      , author = "Jordan Walke"
      , body = "React is a JavaScript library for building user interfaces."
      , id = 1
      , read = False
      }
    , { title = "Redux"
      , author = "Dan Abramov"
      , body = "Redux is a predictable state container for JavaScript apps."
      , id = 2
      , read = False
      }
    , { title = "News Happened"
      , author = "Me"
      , body = "I just learned is awesome!"
      , id = 3
      , read = False
      }
    , { title = "A list of small mice"
      , author = "Me"
      , body = "It's a list of small mice, and they're all dead!"
      , id = 4
      , read = False
      }
    ]


init : Model
init =
    { counter = 0
    , showNav = False
    , stories = initialStories
    }


type Msg
    = Increment
    | Decrement
    | ToggleNav


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            { model | counter = model.counter + 1 }

        Decrement ->
            { model | counter = model.counter - 1 }

        ToggleNav ->
            { model | showNav = not model.showNav }


slot : String -> Html.Attribute Msg
slot slotName =
    Attr.attribute "slot" slotName


storyHeader : Story -> Html Msg
storyHeader story =
    node "bubble-banner"
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
            [ text story.author ]
        ]


storyButton : Story -> Html Msg
storyButton _ =
    node "butt-on"
        [ Attr.attribute "size" "medium"
        , Attr.type_ "tertiary"
        , Attr.attribute "slot" "header-toggle-open"
        , Attr.attribute "icon" "edit"
        , Attr.class "icon-button"
        ]
        [ text "Open" ]


storyView : Story -> Html Msg
storyView story =
    node "roll-up-item"
        [ attribute "clickable" "true" ]
        [ storyHeader story
        , storyButton story
        , article [ slot "content" ]
            [ h1 []
                [ text story.title ]
            , p []
                [ text story.body ]
            , node "butt-on"
                []
                [ text "My Button" ]
            ]
        ]


storiesView : Model -> Html Msg
storiesView model =
    node "roll-up"
        []
        [ div
            [ Attr.attribute "slot" "roll-up-item-list"
            ]
            (List.map storyView model.stories)
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
