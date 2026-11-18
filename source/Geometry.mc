import Toybox.Lang;
import Toybox.Math;

// Polar helpers. Angles are degrees counter-clockwise from 3 o'clock,
// matching Dc.drawArc and Dc.drawRadialText.
module Geometry {

    function x(cx as Numeric, r as Numeric, deg as Numeric) as Numeric {
        return cx + r * Math.cos(Math.toRadians(deg));
    }

    function y(cy as Numeric, r as Numeric, deg as Numeric) as Numeric {
        return cy - r * Math.sin(Math.toRadians(deg));
    }
}
