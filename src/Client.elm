
-- IMPORTS ---------------------------------------------------------------------

port module Main exposing (..)

import Map exposing (..)

import Result.Extra as Result_

import Json.Decode exposing (..)
import Html exposing (..)
-- import Time
import Task
import Mouse
import Window
import Keyboard

import Helper exposing (..)


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
    , persp  : Persp
    -- user
    }

type alias Point = ( Float, Float )

type alias Persp
  = { loc  : Point
    , zoom : Float
    }


-- INIT ------------------------------------------------------------------------

init : ( Model, Cmd Msg )
init
  = { map    = Err "map not defined"
    , screen = { width = 0, height = 0 }
    , persp  = { loc = ( 0.0, 0.0 ), zoom = 1.0 }
    } ! [ Task.perform ScreenResize <| Window.size ]


-- TRANSFORMS ------------------------------------------------------------------

mapPerspLoc : (Point -> Point) -> Model -> Model
mapPerspLoc f = mapPersp (\p -> { p | loc = f p.loc })

mapPerspZoom : (Float -> Float) -> Model -> Model
mapPerspZoom f = mapPersp (\p -> { p | zoom = f p.zoom })
    
mapPersp : (Persp -> Persp) -> Model -> Model
mapPersp f model = setPersp (f model.persp) model

setPersp : Persp -> Model -> Model
setPersp persp_ model
  = let loc__ : ( Float, Float )
        loc__ = persp_.loc
              |> Tuple.mapFirst  mod
              |> Tuple.mapSecond mod
        -- KLUDGE
        mod : Float -> Float
        mod x = if x < 0
                then x + (2 * pi)
                else if x >= (2 * pi)
                     then x - (2 * pi)
                     else x
                                   
    in  { model | persp = { persp_ | loc = loc__ } }


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
  = let keyPersp : Keyboard.KeyCode -> Model -> Model
        keyPersp code
          = case code of
              37 -> mapPerspLoc  (Tuple.mapFirst  <| fl (-) (pi / 8 / model.persp.zoom)) -- left
              38 -> mapPerspLoc  (Tuple.mapSecond <|    (+) (pi / 8 / model.persp.zoom)) -- up
              39 -> mapPerspLoc  (Tuple.mapFirst  <|    (+) (pi / 8 / model.persp.zoom)) -- right
              40 -> mapPerspLoc  (Tuple.mapSecond <| fl (-) (pi / 8 / model.persp.zoom)) -- down
              74 -> mapPerspZoom (                  fl (-)   0.25 ) -- j
              75 -> mapPerspZoom (                     (+)   0.25 ) -- k
              _  -> identity
    in  case msg of
          NoOp              ->   model                   ! []
          MouseMsg     pos  ->   model                   ! []
          KeyMsg       code -> ( model |> keyPersp code ) ! []
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
        -- , Time.every (Time.second    ) (\_ -> KeyMsg 38)
        -- , Time.every (Time.second / 2) (\_ -> KeyMsg 37)
        ]


-- VIEW ------------------------------------------------------------------------

view : Model -> Html Msg
view { map, screen, persp }
  = Result_.unwrap
    (text "error: could not decode map")
    (Map.view screen persp)
    map
    
