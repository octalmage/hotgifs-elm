module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode


main : Program Never Model Msg
main =
    Html.program
        { init = init ""
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { topic : String
    , gifUrl : String
    , enterKeyDown : Bool
    }


init : String -> ( Model, Cmd Msg )
init topic =
    ( Model topic "" False
    , Cmd.none
    )



-- UPDATE


loadingGif : String
loadingGif =
    "https://cdnjs.cloudflare.com/ajax/libs/galleriffic/2.0.1/css/loader.gif"


type Msg
    = FetchGif
    | UpdateTopic String
    | KeyDown Int
    | KeyUp Int
    | NewGif (Result Http.Error String)
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateTopic newTopic ->
            ( { model | topic = newTopic }, Cmd.none )

        KeyDown key ->
            -- TODO: This should be DRY'd.
            if key == 13 && not model.enterKeyDown then
                ( { model | enterKeyDown = True, gifUrl = loadingGif }, getRandomGif model.topic )
            else if key == 9 && model.enterKeyDown then
                ( { model | gifUrl = loadingGif }, getRandomGif model.topic )
            else
                ( model, Cmd.none )

        KeyUp key ->
            if key == 13 then
                ( { model | enterKeyDown = False, topic = "" }, Cmd.none )
            else
                ( model, Cmd.none )

        FetchGif ->
            ( model, getRandomGif model.topic )

        NewGif (Ok newUrl) ->
            ( Model model.topic newUrl model.enterKeyDown, Cmd.none )

        NewGif (Err _) ->
            ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )



-- VIEW
-- To capture tab we need to use this technique to preventDefault:
-- https://github.com/elm/virtual-dom/issues/18#issuecomment-273403774


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown event =
    on "keydown" (Decode.map event keyCode)


onKeyUp : (Int -> msg) -> Attribute msg
onKeyUp event =
    on "keyup" (Decode.map event keyCode)


preventDefaultUpDown : Html.Attribute Msg
preventDefaultUpDown =
    let
        options =
            { defaultOptions | preventDefault = True }

        filterKey code =
            if code == 9 then
                Decode.succeed code
            else
                Decode.fail "ignored input"

        decoder =
            keyCode
                |> Decode.andThen filterKey
                |> Decode.map (always NoOp)
    in
    onWithOptions "keydown" options decoder


view : Model -> Html Msg
view model =
    div
        [ preventDefaultUpDown
        ]
        [ input
            [ value model.topic
            , onInput UpdateTopic
            , onKeyDown KeyDown
            , onKeyUp KeyUp
            ]
            []
        , br [] []
        , img
            [ src model.gifUrl
            , style
                [ ( "display"
                  , if model.enterKeyDown then
                        "block"
                    else
                        "none"
                  )
                ]
            ]
            []
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- HTTP


getRandomGif : String -> Cmd Msg
getRandomGif topic =
    let
        url =
            "https://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=" ++ topic
    in
    Http.send NewGif (Http.get url decodeGifUrl)


decodeGifUrl : Decode.Decoder String
decodeGifUrl =
    Decode.at [ "data", "image_url" ] Decode.string
