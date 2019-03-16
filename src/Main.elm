module Main exposing (Flags(..), Model, Msg(..), Note, init, main, subscriptions, update, view)

import Browser exposing (..)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as D exposing (..)
import Url


main =
    Browser.application
        { init = init
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        , subscriptions = subscriptions
        , update = update
        , view = view
        }



-- MODEL


type alias Model =
    { message : String
    , code : Int
    }


type Flags
    = Int


type alias Note =
    { id : Int
    , author : String
    , content : String
    , created_at : String
    , updated_at : String
    }


init _ url navkey =
    ( { message = "Hi"
      , code = 0
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = Reset
    | UrlChanged Url.Url
    | LinkClicked UrlRequest


update msg model =
    case msg of
        Reset ->
            ( model, Cmd.none )

        UrlChanged _ ->
            ( model, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model, Cmd.none )

                External href ->
                    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : model -> Document msg
view model =
    { title = "New title", body = [] }
