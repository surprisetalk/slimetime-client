
module Map exposing (..)

-- IMPORTS ---------------------------------------------------------------------

import Json.Decode  as Decode  exposing (..)
import Result.Extra as Result_ exposing (..)

-- HELPERS ---------------------------------------------------------------------

singleton : x -> List x
singleton x = [ x ]


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
          "Polygon"      -> coordinatesDecoder_ |> Decode.map singleton
          "MultiPolygon" -> coordinatesDecoder_ |> Decode.list
          _              -> Decode.fail <| "bad shape: " ++ shapeType

coordinatesDecoder_ : Decoder Border
coordinatesDecoder_
    = Decode.map (List.concat >> Result_.combine >> Result.withDefault [])
   <| Decode.list
   <| Decode.list
   <| Decode.map geoListToCoord
   <| Decode.list Decode.float
