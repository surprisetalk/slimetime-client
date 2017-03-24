
module Map exposing (..)

-- IMPORTS ---------------------------------------------------------------------

import Json.Decode  as Decode  exposing (..)
import Result.Extra as Result_ exposing (..)

import Html  exposing (Html)
import Color exposing (..)

import Collage exposing ( defaultLine )
import Element


-- MODEL -----------------------------------------------------------------------

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

view : { width : Int, height : Int } -> Map -> Html msg
view { width, height }
  = let w : Float
        w = toFloat width
        h : Float
        h = toFloat height
        coordToTuple : Coord -> ( Float, Float )
        coordToTuple {x,y} = (x,y)
        -- TODO: we want cover rather than stretch
        geoToScreen : Coord -> Coord
        geoToScreen {x,y} = { x = x / 180 * w / 2
                            , y = y /  90 * h / 2 }
        borderStyle : Collage.LineStyle
        borderStyle = { defaultLine
                        | color = lightCharcoal
                        , width = 1
                      }
        viewBorder : Border -> Collage.Form
        viewBorder = List.map geoToScreen
                  >> List.map coordToTuple
                  >> Collage.path
                  >> Collage.traced borderStyle
        viewMap : Map -> Collage.Form
        viewMap = List.map viewBorder >> Collage.group
        -- TODO: we can fill in the regions by finding a centroid of the border and then generating a bunch of trianges to each border? it'll make the regions convex but whatever
    in  Element.toHtml 
        << Collage.collage width height
        << (::) (Collage.rect w h |> Collage.filled darkCharcoal)
        << viewMap
