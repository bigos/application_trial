module Main exposing (Model, Msg(..), main, subscriptions, update, view)

import Browser exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as D exposing (..)



-- MAIN


main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { message : String
    , code : Int
    }


type alias Flags =
    --empty tuple
    ()


type alias Note =
    { id : Int
    , author : String
    , content : String
    , created_at : String
    , updated_at : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { message = "Hi"
      , code = 0
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = Reset
    | MorePlease
    | GotIt (Result Http.Error Note)



-- update : Msg -> Model -> ( Model, Cmd Msg )


update msg model =
    case msg of
        Reset ->
            ( model, Cmd.none )

        MorePlease ->
            ( { model | code = 1, message = "test" }, getNote )

        GotIt res ->
            case res of
                Ok gottext ->
                    ( { model | message = Debug.toString gottext, code = 1200 }
                    , Cmd.none
                    )

                Err a ->
                    ( { model | message = "error >>> " ++ Debug.toString a }, Cmd.none )


getNote =
    let
        myurl =
            "http://localhost:3000/notes/3"
    in
    Http.get
        { expect = Http.expectJson GotIt itDecoder
        , url = myurl
        }



-- DECODER


itDecoder =
    D.map5 Note
        (field "id" int)
        (field "author" string)
        (field "content" string)
        (field "created_at" string)
        (field "updated_at" string)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view model =
    { title = "My first title"
    , body =
        [ div [] [ text "Hurrah!!!" ]
        , div [] [ text <| String.fromInt model.code ]
        , div [] [ text (Debug.toString model.message) ]
        , div [] [ button [ onClick MorePlease ] [ text "Try Again!" ] ]
        ]
    }
