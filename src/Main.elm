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

    -- person_id : Int
    , authorisation_id : Int
    }


type Status
    = Failure
    | Loading
    | Success String


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
    | GotNotes (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url }
            , Cmd.none
            )

        MoreNotes ->
            ( { model | status = Loading }, getNotes )

        GotNotes result ->
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
            [ viewLink "/spa/home"
            , viewLink "/spa/profile"
            ]
        , button [ onClick MoreNotes, style "display" "block" ] [ text "More Notes!" ]
        , div [] [ text (Debug.toString model) ]
        ]
    }


viewLink : String -> Html msg
viewLink path =
    li [] [ a [ href path ] [ text path ] ]


getNotes =
    Http.get
        { url = "http://spapi/notes"
        , expect = Http.expectJson GotNotes notesDecoder
        }


notesDecoder =
    Json.Decode.list noteDecoder


noteDecoder =
    map2 Note
        (field "id" int)
        (field "authorisation_id" int)
