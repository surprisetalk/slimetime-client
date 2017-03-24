
-- IMPORTS ---------------------------------------------------------------------

port module Main exposing (..)

import Map exposing (..)

import Result.Extra as Result_

import Json.Decode exposing (..)
import Html exposing (..)
import Task
import Mouse
import Window
import Keyboard


-- PORTS -----------------------------------------------------------------------

port cartography : (Value -> msg) -> Sub msg


-- MAIN ------------------------------------------------------------------------

main : Program Never Model Msg
main =
    program
        { init          = init
        , view          = view
        , update        = update
        , subscriptions = subscriptions
        }


-- MODEL -----------------------------------------------------------------------

type alias Model
  = { map    : Result String Map
    , screen : Window.Size
    -- user
    }

init : ( Model, Cmd Msg )
init
  = { map    = Err "map not defined"
    , screen = { width = 0, height = 0 }
    } ! [ Task.perform ScreenResize <| Window.size ]
    

-- MESSAGES --------------------------------------------------------------------

type Msg
  = NoOp
  | MapUpdate (Result String Map)
  | MouseMsg Mouse.Position
  | KeyMsg Keyboard.KeyCode
  | ScreenResize Window.Size


-- UPDATE ----------------------------------------------------------------------

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model
  = case msg of
        NoOp              ->   model                   ! []
        MouseMsg     pos  ->   model                   ! []
        KeyMsg       code ->   model                   ! []
        MapUpdate    map_ -> { model | map    = map_ } ! []
        ScreenResize size -> { model | screen = size } ! []


-- SUBSCRIPTIONS ---------------------------------------------------------------

subscriptions : Model -> Sub Msg
subscriptions model
  = Sub.batch
        [ Mouse.clicks MouseMsg
        , Keyboard.downs KeyMsg
        , cartography (Map.decode >> MapUpdate)
        , Window.resizes ScreenResize
        ]


-- VIEW ------------------------------------------------------------------------

view : Model -> Html Msg
view { map, screen }
  = Result_.unwrap
    (div [] [])
    (Map.view screen)
    map
    
