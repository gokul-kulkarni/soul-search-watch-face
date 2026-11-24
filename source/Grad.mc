import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

// Gradients without native support: vertical gradients redraw a shape once per
// horizontal band, clipped to that band; arc gradients draw short segments.
module Grad {

    const BANDS = 12;
    const HUE_SPREAD = 24.0;   // degrees of hue either side of the base colour
    const SEG_DEG = 2;         // arc gradient segment length

    // Three-stop ramp around a colour: warmer/lighter hue, the colour, cooler/deeper hue.
    function ramp(c as Number) as Array<Number> {
        return [Colors.hueShift(c, HUE_SPREAD), c, Colors.hueShift(c, -HUE_SPREAD)] as Array<Number>;
    }

    function at(stops as Array<Number>, t as Float) as Number {
        if (t <= 0.0) { return stops[0]; }
        if (t >= 1.0) { return stops[stops.size() - 1]; }
        var seg = t * (stops.size() - 1);
        var i = seg.toNumber();
        return Colors.blend(stops[i], stops[i + 1], seg - i);
    }

    function flat(stops as Array<Number>) as Boolean {
        for (var i = 1; i < stops.size(); i++) {
            if (stops[i] != stops[0]) { return false; }
        }
        return true;
    }

    // Paints once per band between top and bottom, clipped and coloured.
    // The outer bands stretch to the screen edges so nothing is cut off.
    function bands(dc as Dc, top as Numeric, bottom as Numeric, stops as Array<Number>,
                   painter as Method(dc as Dc) as Void) as Void {
        if (flat(stops)) {
            dc.setColor(stops[0], Graphics.COLOR_TRANSPARENT);
            painter.invoke(dc);
            return;
        }
        var h = (bottom - top).toFloat() / BANDS;
        var w = dc.getWidth();
        for (var i = 0; i < BANDS; i++) {
            var y0 = i == 0 ? 0 : (top + i * h).toNumber();
            var y1 = i == BANDS - 1 ? dc.getHeight() : (top + (i + 1) * h).toNumber() + 1;
            dc.setClip(0, y0, w, y1 - y0);
            dc.setColor(at(stops, (i + 0.5) / BANDS), Graphics.COLOR_TRANSPARENT);
            painter.invoke(dc);
        }
        dc.clearClip();
    }

    // Arc from -> to (degrees ccw from 3 o'clock), colour running along its length.
    function arc(dc as Dc, cx as Numeric, cy as Numeric, r as Numeric, pen as Number,
                 from as Numeric, to as Numeric, stops as Array<Number>) as Void {
        var sweep = (to - from).toFloat();
        var steps = (sweep.abs() / SEG_DEG).toNumber();
        if (steps < 1) {
            return;
        }
        var step = sweep / steps;
        var dir = step > 0 ? Graphics.ARC_COUNTER_CLOCKWISE : Graphics.ARC_CLOCKWISE;
        var overlap = step > 0 ? 1 : -1;   // hides seams between segments
        dc.setPenWidth(pen);
        for (var i = 0; i < steps; i++) {
            var a0 = from + i * step;
            var a1 = i == steps - 1 ? to : a0 + step + overlap;
            dc.setColor(at(stops, (i + 0.5) / steps), Graphics.COLOR_TRANSPARENT);
            dc.drawArc(cx, cy, r, dir, a0, a1);
        }
        dc.setPenWidth(1);
    }

    // Soft glow: concentric hairline circles fading from the colour at r out to bg.
    function glow(dc as Dc, cx as Numeric, cy as Numeric, r as Numeric, inner as Numeric, outer as Numeric,
                  color as Number, bg as Number, strength as Float) as Void {
        dc.setPenWidth(3);
        for (var d = -inner; d <= outer; d += 2) {
            var t = d < 0 ? (-d).toFloat() / inner : d.toFloat() / outer;
            var fade = 1.0 - strength * (1.0 - Math.pow(t, 0.7).toFloat());
            dc.setColor(Colors.blend(color, bg, fade), Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(cx, cy, r + d);
        }
        dc.setPenWidth(1);
    }
}
