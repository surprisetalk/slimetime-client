
module Helper exposing (..)

fl : (a -> b -> c) -> b -> a -> c
fl = flip     
