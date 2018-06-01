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
    }


init : String -> ( Model, Cmd Msg )
init topic =
    ( Model topic "https://cdnjs.cloudflare.com/ajax/libs/galleriffic/2.0.1/css/loader.gif"
    , Cmd.none
    )



-- UPDATE


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown event =
    on "keydown" (Decode.map event keyCode)


type Msg
    = MorePlease
    | UpdateTopic String
    | KeyDown Int
    | NewGif (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateTopic newTopic ->
            ( { model | topic = newTopic }, Cmd.none )

        KeyDown key ->
            if key == 13 then
                ( model, getRandomGif model.topic )
            else
                ( model, Cmd.none )

        MorePlease ->
            ( model, getRandomGif model.topic )

        NewGif (Ok newUrl) ->
            ( Model model.topic newUrl, Cmd.none )

        NewGif (Err _) ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text model.topic ]
        , input [ value model.topic, onInput UpdateTopic, onKeyDown KeyDown ] []
        , button [ onClick MorePlease, onSubmit MorePlease ] [ text "Search" ]
        , br [] []
        , img [ src model.gifUrl ] []
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
