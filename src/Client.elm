
-- IMPORTS ---------------------------------------------------------------------

port module Main exposing (..)

import Map exposing (..)

import Json.Decode exposing (..)
import Html exposing (..)
import Mouse
import Keyboard


-- PORTS -----------------------------------------------------------------------

port cartography : (Value -> msg) -> Sub msg


-- MAIN ------------------------------------------------------------------------

main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


-- MODEL -----------------------------------------------------------------------

type alias Model
  = { map : Result String Map
    -- user
    }

init : ( Model, Cmd Msg )
init
  = { map = Err "map not defined"
    } ! []
    

-- MESSAGES --------------------------------------------------------------------

type Msg
  = NoOp
  | MapUpdate (Result String Map)
  | MouseMsg Mouse.Position
  | KeyMsg Keyboard.KeyCode


-- UPDATE ----------------------------------------------------------------------

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp               ->   model                ! []
        MouseMsg  position ->   model                ! []
        KeyMsg    code     ->   model                ! []
        MapUpdate map_     -> { model | map = map_ } ! []


-- SUBSCRIPTIONS ---------------------------------------------------------------

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Mouse.clicks MouseMsg
        , Keyboard.downs KeyMsg
        , cartography (Map.decode >> MapUpdate)
        ]


-- VIEW ------------------------------------------------------------------------

view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "HULLO WORLD" ]
        , text (toString model)
        ]
        
