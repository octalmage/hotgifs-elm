module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode


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
    , enterKeyDown: Bool
    }


init : String -> ( Model, Cmd Msg )
init topic =
    ( Model topic "" False
    , Cmd.none
    )

-- UPDATE


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown event =
    on "keydown" (Decode.map event keyCode)

onKeyUp : (Int -> msg) -> Attribute msg
onKeyUp event =
    on "keyup" (Decode.map event keyCode)

loadingGif = "https://cdnjs.cloudflare.com/ajax/libs/galleriffic/2.0.1/css/loader.gif"

type Msg
    = MorePlease
    | UpdateTopic String
    | KeyDown Int
    | KeyUp Int
    | NewGif (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateTopic newTopic ->
            ( { model | topic = newTopic }, Cmd.none )

        KeyDown key ->
            if key == 13 && not model.enterKeyDown then
                ( { model | enterKeyDown = True, gifUrl = loadingGif }, getRandomGif model.topic )
            else
                ( model, Cmd.none )

        KeyUp key ->
            if key == 13 then
                ( { model | enterKeyDown = False }, Cmd.none )
            else
                ( model, Cmd.none )

        MorePlease ->
            ( model, getRandomGif model.topic )

        NewGif (Ok newUrl) ->
            ( Model model.topic newUrl model.enterKeyDown, Cmd.none )

        NewGif (Err _) ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text model.topic ]
        , input [ value model.topic, onInput UpdateTopic, onKeyDown KeyDown, onKeyUp KeyUp ] []
        , button [ onClick MorePlease, onSubmit MorePlease ] [ text "Search" ]
        , br [] []
        , img [ src model.gifUrl, style [("display", if model.enterKeyDown then "block" else "none")] ] []
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
