import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;

// Health and activity glyphs. Same contract as Glyphs.
module GlyphsBody {

    const SHOE_TILT = 36.0;   // degrees; positive lifts the heel, like pushing off

    // Body Battery: person with a lightning bolt on the chest.
    function personBolt(dc as Dc, x as Numeric, y as Numeric, s as Numeric, fg as Number, cut as Number) as Void {
        dc.fillCircle(x, y - s * 0.3, s * 0.19);
        dc.fillRoundedRectangle(x - s * 0.34, y - s * 0.06, s * 0.68, s * 0.56, s * 0.2);
        Glyphs.swap(dc, cut);
        dc.fillPolygon([[x + s * 0.06, y - s * 0.02], [x - s * 0.12, y + s * 0.24], [x - s * 0.01, y + s * 0.24],
                        [x - s * 0.06, y + s * 0.44], [x + s * 0.13, y + s * 0.18], [x + s * 0.02, y + s * 0.18]]);
        Glyphs.swap(dc, fg);
    }

    // Sleep score: bed.
    function bed(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        dc.fillRoundedRectangle(x - s * 0.5, y - s * 0.34, s * 0.12, s * 0.8, s * 0.05);
        dc.fillRoundedRectangle(x - s * 0.5, y + s * 0.12, s * 1.0, s * 0.18, s * 0.05);
        dc.fillRectangle(x + s * 0.4, y + s * 0.12, s * 0.1, s * 0.34);
        dc.fillEllipse(x - s * 0.22, y - s * 0.02, s * 0.13, s * 0.09);
        dc.fillRoundedRectangle(x - s * 0.06, y - s * 0.12, s * 0.56, s * 0.22, s * 0.08);
    }

    // Pulse Ox: drop with oxygen bubbles cut out.
    function pulseOx(dc as Dc, x as Numeric, y as Numeric, s as Numeric, fg as Number, cut as Number) as Void {
        Glyphs.dropShape(dc, x, y, s);
        Glyphs.swap(dc, cut);
        dc.fillCircle(x + s * 0.08, y + s * 0.2, s * 0.12);
        dc.fillCircle(x - s * 0.1, y - s * 0.02, s * 0.06);
        Glyphs.swap(dc, fg);
    }

    function lungs(dc as Dc, x as Numeric, y as Numeric, s as Numeric, fg as Number, cut as Number) as Void {
        dc.fillEllipse(x - s * 0.24, y + s * 0.1, s * 0.2, s * 0.36);
        dc.fillEllipse(x + s * 0.24, y + s * 0.1, s * 0.2, s * 0.36);
        Glyphs.swap(dc, cut);
        dc.setPenWidth(Glyphs.pen(s));
        dc.drawLine(x, y - s * 0.12, x - s * 0.18, y + s * 0.08);
        dc.drawLine(x, y - s * 0.12, x + s * 0.18, y + s * 0.08);
        Glyphs.swap(dc, fg);
        dc.fillRectangle(x - s * 0.05, y - s * 0.5, s * 0.1, s * 0.38);
    }

    // Recovery: clock with a countdown arrow around it.
    function recovery(dc as Dc, x as Numeric, y as Numeric, s as Numeric, fg as Number, cut as Number) as Void {
        dc.fillCircle(x, y, s * 0.28);
        Glyphs.swap(dc, cut);
        dc.setPenWidth(2);
        dc.drawLine(x, y, x, y - s * 0.17);
        dc.drawLine(x, y, x + s * 0.12, y + s * 0.06);
        Glyphs.swap(dc, fg);
        var pw = (s * 0.1).toNumber();
        dc.setPenWidth(pw < 2 ? 2 : pw);
        dc.drawArc(x, y, s * 0.43, Graphics.ARC_COUNTER_CLOCKWISE, 120, 60);
        var a = Math.toRadians(120);
        var tx = x + Math.cos(a) * s * 0.43;
        var ty = y - Math.sin(a) * s * 0.43;
        dc.fillPolygon([[tx - s * 0.16, ty - s * 0.02], [tx + s * 0.06, ty - s * 0.14], [tx + s * 0.04, ty + s * 0.12]]);
    }

    // VO2 max: label badge, the clearest symbol for this metric.
    function vo2(dc as Dc, x as Numeric, y as Numeric, s as Numeric, fg as Number, cut as Number) as Void {
        dc.fillRoundedRectangle(x - s * 0.55, y - s * 0.3, s * 1.1, s * 0.6, s * 0.16);
        Glyphs.swap(dc, cut);
        var f = Fonts.vector(Fonts.FACE_BOLD, (s * 0.5).toFloat());
        dc.drawText(x, y, f == null ? Graphics.FONT_XTINY : f, "VO2", Text.CENTER);
        Glyphs.swap(dc, fg);
    }

    // Intensity minutes: stopwatch with a lightning bolt.
    function stopwatchBolt(dc as Dc, x as Numeric, y as Numeric, s as Numeric, fg as Number, cut as Number) as Void {
        var cy = y + s * 0.08;
        dc.fillCircle(x, cy, s * 0.42);
        dc.fillRoundedRectangle(x - s * 0.12, y - s * 0.52, s * 0.24, s * 0.1, s * 0.04);
        dc.fillRectangle(x - s * 0.04, y - s * 0.44, s * 0.08, s * 0.1);
        Glyphs.swap(dc, cut);
        dc.fillPolygon([[x + s * 0.06, cy - s * 0.3], [x - s * 0.14, cy + s * 0.04], [x - s * 0.01, cy + s * 0.04],
                        [x - s * 0.06, cy + s * 0.3], [x + s * 0.14, cy - s * 0.04], [x + s * 0.01, cy - s * 0.04]]);
        Glyphs.swap(dc, fg);
    }

    // Thick rounded limb from a to b (fractions of s).
    function limb(dc as Dc, x as Numeric, y as Numeric, s as Numeric, a as Array<Float>, b as Array<Float>, w as Float) as Void {
        var pw = (s * w).toNumber();
        dc.setPenWidth(pw < 2 ? 2 : pw);
        dc.drawLine(x + a[0] * s, y + a[1] * s, x + b[0] * s, y + b[1] * s);
        dc.fillCircle(x + a[0] * s, y + a[1] * s, s * w / 2);
        dc.fillCircle(x + b[0] * s, y + b[1] * s, s * w / 2);
    }

    // Vigorous minutes: sprinter with speed lines behind.
    function vigorous(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        sprinter(dc, x + s * 0.12, y, s * 0.9);
        var pw = (s * 0.07).toNumber();
        dc.setPenWidth(pw < 2 ? 2 : pw);
        dc.drawLine(x - s * 0.56, y - s * 0.06, x - s * 0.38, y - s * 0.06);
        dc.drawLine(x - s * 0.6, y + s * 0.08, x - s * 0.4, y + s * 0.08);
        dc.drawLine(x - s * 0.56, y + s * 0.22, x - s * 0.38, y + s * 0.22);
    }

    function sprinter(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        dc.fillCircle(x + s * 0.22, y - s * 0.38, s * 0.12);
        var w = 0.13;
        limb(dc, x, y, s, [0.14, -0.22], [-0.04, 0.06], w);
        limb(dc, x, y, s, [-0.04, 0.06], [0.2, 0.18], w);
        limb(dc, x, y, s, [0.2, 0.18], [0.14, 0.44], w);
        limb(dc, x, y, s, [-0.04, 0.06], [-0.22, 0.26], w);
        limb(dc, x, y, s, [-0.22, 0.26], [-0.44, 0.18], w);
        limb(dc, x, y, s, [0.12, -0.16], [0.32, -0.04], w * 0.85);
        limb(dc, x, y, s, [0.12, -0.16], [-0.12, -0.1], w * 0.85);
        limb(dc, x, y, s, [-0.12, -0.1], [-0.24, -0.26], w * 0.85);
    }

    function flame(dc as Dc, x as Numeric, y as Numeric, s as Numeric, fg as Number, cut as Number) as Void {
        Glyphs.poly(dc, x, y, s, [[0.0, -0.5], [0.14, -0.2], [0.26, -0.34], [0.38, 0.02], [0.34, 0.28],
                                  [0.18, 0.46], [0.0, 0.5], [-0.18, 0.46], [-0.34, 0.28], [-0.36, 0.0], [-0.18, -0.2]]);
        Glyphs.swap(dc, cut);
        dc.fillCircle(x, y + s * 0.26, s * 0.13);
        Glyphs.swap(dc, fg);
    }

    function stairs(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        Glyphs.poly(dc, x, y, s, [[-0.5, 0.45], [-0.5, 0.15], [-0.17, 0.15], [-0.17, -0.15],
                                  [0.17, -0.15], [0.17, -0.45], [0.5, -0.45], [0.5, 0.45]]);
    }

    // Weekly run: tilted running shoe with speed lines over 7 week dots
    // (lit up to today, since watch faces cannot see which days you ran).
    function weeklyRun(dc as Dc, x as Numeric, y as Numeric, s as Numeric, fg as Number, cut as Number) as Void {
        var sy = y - s * 0.12;
        shoe(dc, x + s * 0.1, sy - s * 0.04, s * 0.72, fg, cut);
        var pw = (s * 0.06).toNumber();
        dc.setPenWidth(pw < 2 ? 2 : pw);
        dc.drawLine(x - s * 0.5, sy + s * 0.08, x - s * 0.3, sy + s * 0.08);
        dc.drawLine(x - s * 0.54, sy + s * 0.2, x - s * 0.32, sy + s * 0.2);
        var lit = daysIntoWeek();
        var dim = Colors.blend(cut, fg, 0.35);
        for (var i = 0; i < 7; i++) {
            Glyphs.swap(dc, i < lit ? fg : dim);
            dc.fillCircle(x - s * 0.42 + i * s * 0.14, y + s * 0.42, s * 0.05);
        }
        Glyphs.swap(dc, fg);
    }

    function daysIntoWeek() as Number {
        var dow = Gregorian.info(Time.now(), Time.FORMAT_SHORT).day_of_week as Number;   // 1 = Sunday
        var first = 2;   // Monday unless the watch says otherwise
        var ds = System.getDeviceSettings();
        if (ds has :firstDayOfWeek) {
            var f = ds.firstDayOfWeek;
            if (f instanceof Number) { first = f; }
        }
        return ((dow - first + 7) % 7) + 1;
    }

    // Rotates a point (fractions of s) by SHOE_TILT around the centre.
    function rot(x as Numeric, y as Numeric, s as Numeric, px as Float, py as Float) as Graphics.Point2D {
        var a = Math.toRadians(SHOE_TILT);
        var c = Math.cos(a);
        var n = Math.sin(a);
        return [x + (px * c - py * n) * s, y + (px * n + py * c) * s];
    }

    // Running shoe in side view: curved upper, rocker sole, midsole and lace cuts.
    function shoe(dc as Dc, x as Numeric, y as Numeric, s as Numeric, fg as Number, cut as Number) as Void {
        var outline = [
            [-0.48, 0.12], [-0.5, -0.04], [-0.47, -0.2], [-0.4, -0.3], [-0.3, -0.31], [-0.24, -0.2],
            [-0.14, -0.14], [-0.02, -0.16], [0.08, -0.24], [0.17, -0.25], [0.24, -0.15], [0.32, -0.06],
            [0.42, 0.0], [0.5, 0.08], [0.52, 0.16]
        ] as Array<Array<Float>>;
        for (var i = 0; i <= 8; i++) {
            var t = i / 8.0;
            outline.add([0.52 - t * 1.0, (0.2 + 0.2 * Math.sin(Math.PI * t)).toFloat()]);
        }
        var poly = [] as Array<Graphics.Point2D>;
        for (var i = 0; i < outline.size(); i++) {
            poly.add(rot(x, y, s, outline[i][0], outline[i][1]));
        }
        dc.fillPolygon(poly);
        Glyphs.swap(dc, cut);
        var pw = (s * 0.06).toNumber();
        dc.setPenWidth(pw < 2 ? 2 : pw);
        for (var i = 0; i < 6; i++) {
            var t0 = i / 6.0;
            var t1 = (i + 1) / 6.0;
            var a = rot(x, y, s, 0.46 - t0 * 0.92, (0.12 + 0.17 * Math.sin(Math.PI * t0)).toFloat());
            var b = rot(x, y, s, 0.46 - t1 * 0.92, (0.12 + 0.17 * Math.sin(Math.PI * t1)).toFloat());
            dc.drawLine(a[0], a[1], b[0], b[1]);
        }
        var laces = [[-0.04, -0.06, 0.05, -0.14], [0.06, 0.0, 0.14, -0.09], [0.16, 0.05, 0.23, -0.03]];
        for (var i = 0; i < laces.size(); i++) {
            var l = laces[i];
            var a = rot(x, y, s, l[0], l[1]);
            var b = rot(x, y, s, l[2], l[3]);
            dc.drawLine(a[0], a[1], b[0], b[1]);
        }
        Glyphs.swap(dc, fg);
    }
}
