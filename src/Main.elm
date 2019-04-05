module Main exposing (Model, Msg(..), init, main, subscriptions, update, view, viewLink)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (..)
import Url



-- MAIN


main : Program () Model Msg
main =
    -- it worked with the elm reactor, it needs some kind of server
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , status : Status
    }


type alias Note =
    { id : Int
    , person_id : Int
    , authorisation_id : Int
    , content : String
    }


type Status
    = Failure
    | Loading
    | Success (List Note)


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( Model key url Loading
    , Cmd.none
    )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | MoreNotes
    | GotNotes (Result Http.Error (List Note))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            let
                boo =
                    Debug.log (Debug.toString urlRequest)
                        1
            in
            case urlRequest of
                Browser.Internal url ->
                    let
                        urlStr =
                            Url.toString url

                        spaPage =
                            String.startsWith "/spa/" urlStr
                    in
                    if spaPage then
                        ( model, Nav.pushUrl model.key (Url.toString url) )

                    else
                        ( model, Nav.load urlStr )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url }
            , Cmd.none
            )

        MoreNotes ->
            ( { model | status = Loading }, getNotes model )

        GotNotes result ->
            let
                foo =
                    Debug.log (Debug.toString result)
                        1
            in
            case result of
                Ok url ->
                    ( { model | status = Success url }, Cmd.none )

                Err _ ->
                    ( { model | status = Failure }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "URL Interceptor Experiment"
    , body =
        [ text "The current URL is: "
        , b [] [ text (Url.toString model.url) ]
        , ul []
            [ li [] [ a [ href "/" ] [ text "Home" ] ]
            , viewLink "/spa/home"
            , viewLink "/spa/profile"
            ]
        , button [ onClick MoreNotes, style "display" "block" ] [ text "More Notes!" ]
        , div [] [ text (Debug.toString model) ]
        ]
    }


viewLink : String -> Html msg
viewLink path =
    li [] [ a [ href path ] [ text path ] ]


getNotes model =
    let
        nurl =
            "http://localhost:"
                ++ (case model.url.port_ of
                        Nothing ->
                            ""

                        Just p ->
                            String.fromInt p
                   )
                ++ "/spapi/notes.json"
    in
    Http.get
        { url = nurl
        , expect = Http.expectJson GotNotes notesDecoder
        }


notesDecoder =
    Json.Decode.list noteDecoder


noteDecoder =
    map4 Note
        (field "id" int)
        (field "person_id" int)
        (field "authorisation_id" int)
        (field "content" string)
