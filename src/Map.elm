
module Map exposing (..)

-- IMPORTS ---------------------------------------------------------------------

import Json.Decode  as Decode  exposing (..)
import Result.Extra as Result_ exposing (..)

import Html  exposing (Html)
import Color exposing (..)

import Collage exposing ( defaultLine )
import Element

import Window


-- MODEL -----------------------------------------------------------------------

type alias Point = ( Float, Float )

type alias Persp
  = { loc  : Point
    , zoom : Float
    }

type alias Coord
    = { x : Float
      , y : Float
      }

-- TODO: do coord lists start and end with the same coord?
type alias Border = List Coord

type alias Map = List Border


-- TRANSFORMS ------------------------------------------------------------------

geoListToCoord : List Float -> Result String Coord
geoListToCoord lst
    = case lst of
          [ x, y ] -> Ok  <| Coord x y
          _        -> Err <| "could not parse list " ++ toString lst ++ " into tuple"


-- DECODER ---------------------------------------------------------------------

decode : Value -> Result String Map
decode = decodeValue cartographyDecoder

cartographyDecoder : Decoder Map
cartographyDecoder
    = Decode.field "features"
    <| Decode.map List.concat
    <| Decode.list featureDecoder

featureDecoder : Decoder Map
featureDecoder
    = Decode.field "geometry"
    <| Decode.andThen coordinatesDecoder
    <| Decode.field "type" Decode.string


coordinatesDecoder : String -> Decoder Map
coordinatesDecoder shapeType
    = Decode.field "coordinates"
    <| case shapeType of
           "Polygon"      -> coordinatesDecoder_ |> Decode.map List.singleton
           "MultiPolygon" -> coordinatesDecoder_ |> Decode.list
           _              -> Decode.fail <| "bad shape: " ++ shapeType

coordinatesDecoder_ : Decoder Border
coordinatesDecoder_
    = Decode.map (List.concat >> Result_.combine >> Result.withDefault [])
    <| Decode.list
    <| Decode.list
    <| Decode.map geoListToCoord
    <| Decode.list Decode.float


-- DECODER ---------------------------------------------------------------------

-- -- TODO: use html touch/scroll interactions to take over zoom?
view : Window.Size -> Persp -> Map -> Html msg
view { width, height } { loc, zoom } map
  = let w : Float
        w = toFloat width
        h : Float
        h = toFloat height
        m : Float
        m = max w h
        coordToPoint : Coord -> Point
        coordToPoint {x,y} = (x,y)
        -- TODO: need a modulo to wrap-around
        geoToScreen : Coord -> Coord
        geoToScreen {x,y} = { x = x / 180 * m / 2 + Tuple.first  loc |> (*) zoom
                            , y = y /  90 * m / 2 + Tuple.second loc |> (*) zoom }
        formMap : Collage.Form
        formMap = map
                |> List.map formBorder
                |> Collage.group
        formBorder : Border -> Collage.Form
        formBorder = List.map geoToScreen
                   >> List.map coordToPoint
                   >> Collage.path
                   >> Collage.traced borderStyle
        formBackground : Collage.Form
        formBackground = Collage.rect w h
                       |> Collage.filled darkCharcoal
        borderStyle : Collage.LineStyle
        borderStyle = { defaultLine
                        | color = lightCharcoal
                        , width = 1
                      }
    in  [ formBackground, formMap ]
        |> Collage.collage width height
        |> Element.toHtml

