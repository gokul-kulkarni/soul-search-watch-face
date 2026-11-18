import Toybox.Graphics;
import Toybox.Lang;

// Seven-segment digits drawn as slanted hexagonal bars, instrument style.
// Segment bits: a=top, b=top-right, c=bottom-right, d=bottom, e=bottom-left,
// f=top-left, g=middle.
module Segments {

    const MASKS = [63, 6, 91, 79, 102, 109, 125, 7, 127, 111] as Array<Number>;
    const WIDTH_RATIO = 0.56;   // digit width / height
    const THICK_RATIO = 0.13;   // bar thickness / height
    const GAP_RATIO = 0.16;     // space between digits / height
    const SKEW = 0.1;           // italic slant

    // HH:MM centred on (cx, cy). offColor draws unlit segments; null skips them.
    function drawTime(dc as Dc, cx as Numeric, cy as Numeric, h as Numeric,
                      hourColor as Number, minuteColor as Number, colonColor as Number, offColor as Number?) as Void {
        var p = Clock.stackedParts();
        var w = h * WIDTH_RATIO;
        var gap = h * GAP_RATIO;
        var colonW = h * 0.22;
        var total = 4 * w + 2 * gap + 2 * gap + colonW;
        var x = cx - total / 2;
        var top = cy - h / 2;
        var digits = p[0] + p[1];
        for (var i = 0; i < 4; i++) {
            var ch = digits.substring(i, i + 1);
            var d = ch == null ? null : ch.toNumber();
            var color = i < 2 ? hourColor : minuteColor;
            digit(dc, d == null ? 0 : d, x, top, w, h, color, offColor);
            x += w + gap;
            if (i == 1) {
                colon(dc, x + colonW / 2 - gap / 2, cy, h, colonColor);
                x += colonW + gap;
            }
        }
    }

    function digit(dc as Dc, d as Number, x as Numeric, y as Numeric, w as Numeric, h as Numeric,
                   on as Number, off as Number?) as Void {
        var mask = MASKS[d];
        for (var seg = 0; seg < 7; seg++) {
            var lit = (mask & (1 << seg)) != 0;
            if (!lit && off == null) {
                continue;
            }
            dc.setColor(lit ? on : off as Number, Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon(segment(seg, x, y, w, h));
        }
    }

    function colon(dc as Dc, x as Numeric, cy as Numeric, h as Numeric, color as Number) as Void {
        var s = h * THICK_RATIO;
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x - s / 2 + h * 0.05, cy - h * 0.22 - s / 2, s, s);
        dc.fillRectangle(x - s / 2 - h * 0.03, cy + h * 0.18 - s / 2, s, s);
    }

    // Polygon for one segment of a digit whose box is (x, y, w, h).
    function segment(seg as Number, x as Numeric, y as Numeric, w as Numeric, h as Numeric) as Array<Graphics.Point2D> {
        var t = h * THICK_RATIO;
        var g = t * 0.18;
        var l = x + t / 2;
        var rgt = x + w - t / 2;
        var top = y + t / 2;
        var mid = y + h / 2;
        var bot = y + h - t / 2;
        var pts;
        switch (seg) {
            case 0:  pts = bar(l + g, rgt - g, top, t, true); break;
            case 1:  pts = bar(top + g, mid - g, rgt, t, false); break;
            case 2:  pts = bar(mid + g, bot - g, rgt, t, false); break;
            case 3:  pts = bar(l + g, rgt - g, bot, t, true); break;
            case 4:  pts = bar(mid + g, bot - g, l, t, false); break;
            case 5:  pts = bar(top + g, mid - g, l, t, false); break;
            default: pts = bar(l + g, rgt - g, mid, t, true); break;
        }
        return slant(pts, mid);
    }

    // Hexagonal bar from a to b along one axis, centred at c on the other.
    function bar(a as Numeric, b as Numeric, c as Numeric, t as Numeric, horizontal as Boolean) as Array<Array<Numeric>> {
        var k = t / 2;
        if (horizontal) {
            return [[a, c], [a + k, c - k], [b - k, c - k], [b, c], [b - k, c + k], [a + k, c + k]];
        }
        return [[c, a], [c + k, a + k], [c + k, b - k], [c, b], [c - k, b - k], [c - k, a + k]];
    }

    function slant(pts as Array<Array<Numeric>>, mid as Numeric) as Array<Graphics.Point2D> {
        var out = [] as Array<Graphics.Point2D>;
        for (var i = 0; i < pts.size(); i++) {
            out.add([pts[i][0] + (mid - pts[i][1]) * SKEW, pts[i][1]]);
        }
        return out;
    }
}
