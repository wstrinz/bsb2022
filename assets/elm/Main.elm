module Main exposing (..)

import Browser
import Html exposing (Html, a, article, aside, button, div, figcaption, figure, h1, img, li, node, p, section, text, ul)
import Html.Attributes as Attr exposing (attribute, href)
import Html.Events exposing (onClick)


main : Program () Model Msg
main =
    Browser.sandbox { init = init, update = update, view = view }


type alias Model =
    { counter : Int
    , showNav : Bool
    }


init : Model
init =
    { counter = 0
    , showNav = True
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


bones : Model -> Html Msg
bones model =
    div [ Attr.id "grid", Attr.class "hide-right-sidebar" ]
        [ div [ Attr.id "left" ]
            [ div [ Attr.id "top-nav" ]
                [ a [ Attr.tabindex 1, Attr.title "Open Nav", onClick ToggleNav ]
                    [ node "drip-illo" [ Attr.size 36, Attr.name "Medium Audience" ] []
                    ]
                ]
            ]
        , div
            [ Attr.id "main" ]
            [ node "drip-bones"
                []
                [ section [ attribute "width" "full", attribute "layout" "centered" ]
                    [ article []
                        [ h1 []
                            [ text ("Walrus" ++ String.fromInt model.counter) ]
                        , p []
                            [ text "The walrus is a large flippered marine mammal with a discontinuous distribution about the North Pole in the Arctic Ocean and subarctic seas of the Northern Hemisphere." ]
                        , node "butt-on"
                            []
                            [ text "My Button" ]
                        ]
                    , aside []
                        [ figure
                            [ Attr.class "tight"
                            ]
                            [ img
                                [ Attr.src "https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/Pacific_Walrus_-_Bull_%288247646168%29.jpg/1200px-Pacific_Walrus_-_Bull_%288247646168%29.jpg"
                                ]
                                []
                            ]
                        , figcaption []
                            [ text "Walrus knows your fears" ]
                        ]
                    ]
                , section
                    [ Attr.class "mt-4"
                    ]
                    [ article []
                        [ h1 []
                            [ text "Penguin" ]
                        , p []
                            [ text "Penguins are a group of aquatic flightless birds. They live almost exclusively in the Southern Hemisphere, with only one species, the Galápagos penguin, found north of the equator." ]
                        ]
                    , aside []
                        [ figure
                            [ Attr.class "tight"
                            ]
                            [ img
                                [ Attr.src "https://www.morrishospital.org/wp-content/uploads/2018/12/penguin2_2-1024x768.jpg"
                                ]
                                []
                            ]
                        , figcaption []
                            [ text "There are penguins plotting your downfall" ]
                        ]
                    ]
                ]
            ]
        , div [ Attr.id "right", attribute "data-component" "right-sidebar" ] [ text "hi" ]
        ]


view : Model -> Html Msg
view model =
    bones model
