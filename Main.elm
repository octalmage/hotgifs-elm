module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import Style


main : Program Never Model Msg
main =
    Html.program
        { init = init ""
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type Instruction
    = Preview
    | Skip
    | NoResults
    | None


type alias Model =
    { topic : String
    , gifUrl : String
    , enterKeyDown : Bool
    , instruction : Instruction
    }


init : String -> ( Model, Cmd Msg )
init topic =
    ( Model topic loadingGif False None
    , Cmd.none
    )



-- UPDATE


loadingGif : String
loadingGif =
    "/src/load.gif"


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
            -- Remove instruction if topic is empty.
            let
                instruction =
                    case newTopic of
                        "" ->
                            None

                        _ ->
                            Preview
            in
            ( { model | topic = newTopic, instruction = instruction }, Cmd.none )

        KeyDown key ->
            if key == 13 && not model.enterKeyDown then
                update FetchGif { model | enterKeyDown = True, instruction = Skip }
            else if key == 9 && model.enterKeyDown then
                update FetchGif { model | gifUrl = loadingGif, instruction = None }
            else
                ( model, Cmd.none )

        KeyUp key ->
            if key == 13 then
                ( { model | enterKeyDown = False, topic = "", instruction = None, gifUrl = loadingGif }, Cmd.none )
            else
                ( model, Cmd.none )

        FetchGif ->
            ( model, getRandomGif model.topic )

        NewGif (Ok newUrl) ->
            ( { model | gifUrl = newUrl }, Cmd.none )

        NewGif (Err _) ->
            ( { model | instruction = NoResults, gifUrl = "" }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )



-- VIEW


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown event =
    on "keydown" (Decode.map event keyCode)


onKeyUp : (Int -> msg) -> Attribute msg
onKeyUp event =
    on "keyup" (Decode.map event keyCode)



-- To capture tab we need to use this technique to preventDefault:
-- https://github.com/elm/virtual-dom/issues/18#issuecomment-273403774


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
    div [ Style.container model.enterKeyDown ]
        [ div
            [ preventDefaultUpDown
            ]
            [ input
                [ value model.topic
                , onInput UpdateTopic
                , onKeyDown KeyDown
                , onKeyUp KeyUp
                , Style.input
                ]
                []
            ]
        , div [ Style.scene ]
            [ img
                [ src model.gifUrl
                , Style.gif model.enterKeyDown
                ]
                []
            ]
        , div [ Style.instructions ]
            [ text
                (case model.instruction of
                    Preview ->
                        "Hold enter to preview."

                    Skip ->
                        "Press tab to skip."

                    NoResults ->
                        "No Results."

                    None ->
                        ""
                )
            ]
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
