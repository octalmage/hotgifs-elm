module Style exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


backgroundColor : String
backgroundColor =
    "#FF69B4"


container : Bool -> Attribute msg
container enterKeyDown =
    style
        [ ( "background-color", backgroundColor )
        , ( "width", "500px" )
        , ( "height"
          , if enterKeyDown then
                "270px"
            else
                "60px"
          )
        , ( "font-family", """"Lucida Sans Unicode", "Lucida Grande", sans-serif""" )
        ]


input : Attribute msg
input =
    style
        [ ( "border", "0" )
        , ( "color", "white" )
        , ( "background-color", backgroundColor )
        , ( "font-size", "48px" )
        , ( "width", "498px" )
        , ( "text-align", "center" )
        , ( "outline", "none" )
        , ( "background", "url(src/g.png) no-repeat right bottom" )
        , ( "background-size", "75px" )
        ]


instructions : Attribute msg
instructions =
    style
        [ ( "position", "fixed" )
        , ( "left", "0px" )
        , ( "top", "45px" )
        , ( "font-size", "12px" )
        , ( "opacity", "0.5" )
        , ( "color", "white" )
        , ( "transition", "opacity 0.8s" )
        ]


scene : Attribute msg
scene =
    style
        [ ( "height", "200px" )
        , ( "width", "100%" )
        ]


gif : Bool -> Attribute msg
gif enterKeyDown =
    style
        [ ( "margin", "0 auto" )
        , ( "max-height", "200px" )
        , ( "max-width", "100%" )
        , ( "text-align", "center" )
        , ( "position", "relative" )
        , ( "top", "50%" )
        , ( "transform", "translateY(-50%)" )
        , ( "display"
          , if enterKeyDown then
                "block"
            else
                "none"
          )
        ]
