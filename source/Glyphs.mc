import Toybox.Graphics;
import Toybox.Lang;

// Core solid glyph shapes shared by the icon set. Every glyph is centred on
// (x, y) in a box of side s. fg = glyph colour, cut = colour of cut-outs
// (the background).
module Glyphs {

    function pen(s as Numeric) as Number {
        var p = (s / 8).toNumber();
        return p < 2 ? 2 : p;
    }

    function poly(dc as Dc, x as Numeric, y as Numeric, s as Numeric, pts as Array<Array<Float>>) as Void {
        var out = [] as Array<Graphics.Point2D>;
        for (var i = 0; i < pts.size(); i++) {
            out.add([x + pts[i][0] * s, y + pts[i][1] * s]);
        }
        dc.fillPolygon(out);
    }

    function swap(dc as Dc, c as Number) as Void {
        dc.setColor(c, Graphics.COLOR_TRANSPARENT);
    }

    function heart(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        var r = s * 0.27;
        dc.fillCircle(x - s * 0.24, y - s * 0.12, r);
        dc.fillCircle(x + s * 0.24, y - s * 0.12, r);
        dc.fillPolygon([[x - s * 0.5, y - s * 0.03], [x + s * 0.5, y - s * 0.03], [x, y + s * 0.47]]);
    }

    function moon(dc as Dc, x as Numeric, y as Numeric, s as Numeric, fg as Number, cut as Number) as Void {
        dc.fillCircle(x - s * 0.04, y + s * 0.02, s * 0.44);
        swap(dc, cut);
        dc.fillCircle(x + s * 0.2, y - s * 0.16, s * 0.36);
        swap(dc, fg);
    }

    function steps(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        foot(dc, x - s * 0.2, y + s * 0.08, s);
        foot(dc, x + s * 0.2, y - s * 0.14, s);
    }

    function foot(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        dc.fillEllipse(x, y - s * 0.06, s * 0.16, s * 0.24);
        dc.fillCircle(x, y + s * 0.28, s * 0.11);
    }

    // Disc with a zigzag cut through it.
    function stress(dc as Dc, x as Numeric, y as Numeric, s as Numeric, fg as Number, cut as Number) as Void {
        dc.fillCircle(x, y, s * 0.47);
        swap(dc, cut);
        dc.setPenWidth(pen(s));
        var w = s * 0.72;
        var pts = [[-0.5, 0.0], [-0.25, -0.28], [0.0, 0.28], [0.25, -0.28], [0.5, 0.0]];
        for (var i = 1; i < pts.size(); i++) {
            dc.drawLine(x + pts[i - 1][0] * w, y + pts[i - 1][1] * w, x + pts[i][0] * w, y + pts[i][1] * w);
        }
        swap(dc, fg);
    }

    // Horizontal battery showing the real charge level.
    function battery(dc as Dc, x as Numeric, y as Numeric, s as Numeric, fg as Number, cut as Number, frac as Float?) as Void {
        var left = x - s * 0.5;
        var top = y - s * 0.27;
        var w = s * 0.88;
        var h = s * 0.54;
        dc.fillRoundedRectangle(left, top, w, h, s * 0.1);
        dc.fillRoundedRectangle(left + w, y - s * 0.11, s * 0.12, s * 0.22, s * 0.04);
        var inset = s * 0.1;
        var level = frac == null ? 1.0 : frac;
        var innerW = w - 2 * inset;
        swap(dc, cut);
        dc.fillRectangle(left + inset + innerW * level, top + inset, innerW * (1 - level), h - 2 * inset);
        swap(dc, fg);
    }

    function cloud(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        dc.fillCircle(x - s * 0.18, y + s * 0.02, s * 0.2);
        dc.fillCircle(x + s * 0.08, y - s * 0.08, s * 0.25);
        dc.fillRoundedRectangle(x - s * 0.42, y, s * 0.8, s * 0.24, s * 0.12);
    }

    function bell(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        dc.fillCircle(x, y - s * 0.44, s * 0.07);
        dc.fillCircle(x, y - s * 0.1, s * 0.3);
        dc.fillPolygon([[x - s * 0.3, y - s * 0.1], [x + s * 0.3, y - s * 0.1], [x + s * 0.44, y + s * 0.28], [x - s * 0.44, y + s * 0.28]]);
        dc.fillRoundedRectangle(x - s * 0.47, y + s * 0.24, s * 0.94, s * 0.08, s * 0.04);
        dc.fillCircle(x, y + s * 0.42, s * 0.09);
    }

    function thermometer(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        dc.fillRoundedRectangle(x - s * 0.11, y - s * 0.5, s * 0.22, s * 0.72, s * 0.11);
        dc.fillCircle(x, y + s * 0.3, s * 0.2);
    }

    function dropShape(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        dc.fillCircle(x, y + s * 0.15, s * 0.32);
        poly(dc, x, y, s, [[0.0, -0.5], [0.29, 0.02], [-0.29, 0.02]]);
    }

    // Calendar page; withEvent shows an event slot instead of the day grid.
    function calendar(dc as Dc, x as Numeric, y as Numeric, s as Numeric, fg as Number, cut as Number, withEvent as Boolean) as Void {
        dc.fillRoundedRectangle(x - s * 0.44, y - s * 0.36, s * 0.88, s * 0.84, s * 0.1);
        dc.fillRoundedRectangle(x - s * 0.26, y - s * 0.5, s * 0.1, s * 0.2, s * 0.04);
        dc.fillRoundedRectangle(x + s * 0.16, y - s * 0.5, s * 0.1, s * 0.2, s * 0.04);
        swap(dc, cut);
        dc.fillRectangle(x - s * 0.44, y - s * 0.14, s * 0.88, s * 0.06);
        if (withEvent) {
            dc.fillRoundedRectangle(x - s * 0.32, y - s * 0.02, s * 0.64, s * 0.38, s * 0.06);
            swap(dc, fg);
            dc.fillCircle(x - s * 0.17, y + s * 0.17, s * 0.08);
            dc.fillRoundedRectangle(x - s * 0.04, y + s * 0.13, s * 0.26, s * 0.08, s * 0.04);
            return;
        }
        for (var r = 0; r < 2; r++) {
            for (var c = 0; c < 3; c++) {
                dc.fillRectangle(x - s * 0.3 + c * s * 0.23, y + s * 0.02 + r * s * 0.2, s * 0.14, s * 0.12);
            }
        }
        swap(dc, fg);
    }
}
