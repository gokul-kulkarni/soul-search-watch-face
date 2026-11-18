import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

// Field icons drawn from primitives so they can take any (dynamic) colour.
// All icons are centred on (x, y) and fit in a box of side s.
module Icons {

    function draw(dc as Dc, field as Number, x as Numeric, y as Numeric, s as Numeric, color as Number, frac as Float?) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(pen(s));
        switch (field) {
            case Fields.HEART_RATE:    heart(dc, x, y, s); break;
            case Fields.STEPS:         steps(dc, x, y, s); break;
            case Fields.BATTERY:       battery(dc, x, y, s, frac); break;
            case Fields.BODY_BATTERY:  bodyBattery(dc, x, y, s, color, frac); break;
            case Fields.STRESS:        zigzag(dc, x, y, s); break;
            case Fields.CALORIES:      flame(dc, x, y, s); break;
            case Fields.FLOORS:        stairs(dc, x, y, s); break;
            case Fields.ACTIVE_MIN:    stopwatch(dc, x, y, s); break;
            case Fields.NOTIFICATIONS: bell(dc, x, y, s); break;
            case Fields.TEMPERATURE:   thermometer(dc, x, y, s); break;
            case Fields.SUN_EVENT:     sun(dc, x, y, s); break;
            case Fields.RECOVERY:      hourglass(dc, x, y, s); break;
            case Fields.DATE:
            case Fields.CALENDAR:      calendar(dc, x, y, s); break;
            default:                   IconsExtra.dispatch(dc, field, x, y, s, color); break;
        }
        dc.setPenWidth(1);
    }

    function pen(s as Numeric) as Number {
        var p = (s / 9).toNumber();
        return p < 2 ? 2 : p;
    }

    function heart(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        var r = s * 0.26;
        dc.fillCircle(x - r * 0.95, y - s * 0.12, r);
        dc.fillCircle(x + r * 0.95, y - s * 0.12, r);
        dc.fillPolygon([[x - s * 0.5, y - s * 0.04], [x + s * 0.5, y - s * 0.04], [x, y + s * 0.46]]);
    }

    function steps(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        dc.fillEllipse(x - s * 0.2, y + s * 0.08, s * 0.13, s * 0.24);
        dc.fillEllipse(x + s * 0.2, y - s * 0.12, s * 0.13, s * 0.24);
        dc.fillCircle(x - s * 0.2, y + s * 0.43, s * 0.09);
        dc.fillCircle(x + s * 0.2, y + s * 0.23, s * 0.09);
    }

    function battery(dc as Dc, x as Numeric, y as Numeric, s as Numeric, frac as Float?) as Void {
        var w = s * 0.86;
        var h = s * 0.5;
        var left = x - s * 0.5;
        var top = y - h / 2;
        dc.drawRoundedRectangle(left, top, w, h, s * 0.08);
        dc.fillRectangle(left + w, y - s * 0.1, s * 0.12, s * 0.2);
        var level = frac == null ? 1.0 : frac;
        var inset = s * 0.12;
        dc.fillRectangle(left + inset, top + inset, (w - 2 * inset) * level, h - 2 * inset);
    }

    // Upright battery filled to the Body Battery level, with a bolt cut through it.
    function bodyBattery(dc as Dc, x as Numeric, y as Numeric, s as Numeric, color as Number, frac as Float?) as Void {
        var w = s * 0.56;
        var h = s * 0.84;
        var left = x - w / 2;
        var top = y - h / 2 + s * 0.08;
        dc.fillRectangle(x - s * 0.1, top - s * 0.1, s * 0.2, s * 0.1);
        dc.drawRoundedRectangle(left, top, w, h, s * 0.08);
        var inset = s * 0.1;
        var innerH = h - 2 * inset;
        var level = frac == null ? 1.0 : frac;
        var fillH = innerH * level;
        dc.fillRectangle(left + inset, top + inset + innerH - fillH, w - 2 * inset, fillH);

        var bolt = [
            [x + s * 0.08, top + inset * 0.6], [x - s * 0.16, y + s * 0.1], [x, y + s * 0.1],
            [x - s * 0.08, top + h - inset * 0.6], [x + s * 0.16, y + s * 0.0], [x, y + s * 0.0]
        ];
        dc.setColor(Theme.color(Theme.BG), Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(bolt);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        for (var i = 0; i < bolt.size(); i++) {
            var a = bolt[i];
            var b = bolt[(i + 1) % bolt.size()];
            dc.drawLine(a[0], a[1], b[0], b[1]);
        }
        dc.setPenWidth(pen(s));
    }

    function zigzag(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        polyline(dc, x, y, s, [[-0.5, 0.0], [-0.3, -0.3], [-0.1, 0.3], [0.1, -0.3], [0.3, 0.3], [0.5, 0.0]]);
    }

    // Flame with a side lick and a hollow core, so it never reads as a water drop.
    function flame(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        var pts = [[0.0, -0.5], [0.14, -0.2], [0.26, -0.34], [0.38, 0.02], [0.34, 0.28],
                   [0.18, 0.46], [0.0, 0.5], [-0.18, 0.46], [-0.34, 0.28], [-0.36, 0.0], [-0.18, -0.2]];
        dc.fillPolygon(IconsExtra.scaled(x, y, s, pts));
        var color = Theme.color(Theme.BG);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x, y + s * 0.26, s * 0.13);
    }

    function stairs(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        polyline(dc, x, y, s, [[-0.5, 0.45], [-0.17, 0.45], [-0.17, 0.12], [0.17, 0.12], [0.17, -0.22], [0.5, -0.22]]);
    }

    function stopwatch(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        var cy = y + s * 0.06;
        dc.drawCircle(x, cy, s * 0.4);
        dc.drawLine(x, cy, x, cy - s * 0.24);
        dc.drawLine(x, cy, x + s * 0.18, cy);
        dc.fillRectangle(x - s * 0.1, y - s * 0.52, s * 0.2, s * 0.08);
    }

    function bell(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        dc.fillCircle(x, y - s * 0.12, s * 0.28);
        dc.fillPolygon([[x - s * 0.28, y - s * 0.12], [x + s * 0.28, y - s * 0.12], [x + s * 0.42, y + s * 0.3], [x - s * 0.42, y + s * 0.3]]);
        dc.fillCircle(x, y + s * 0.42, s * 0.09);
    }

    function thermometer(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        dc.drawRoundedRectangle(x - s * 0.16, y - s * 0.5, s * 0.32, s * 0.7, s * 0.16);
        dc.fillRectangle(x - s * 0.05, y - s * 0.22, s * 0.1, s * 0.4);
        dc.fillCircle(x, y + s * 0.28, s * 0.24);
    }

    function sun(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        dc.fillCircle(x, y, s * 0.2);
        IconsExtra.rays(dc, x, y, s, Sun.isNextSunrise() ? 8 : 4, 0.32);
    }

    function hourglass(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        dc.fillPolygon([[x - s * 0.34, y - s * 0.5], [x + s * 0.34, y - s * 0.5], [x, y]]);
        dc.fillPolygon([[x, y], [x + s * 0.34, y + s * 0.5], [x - s * 0.34, y + s * 0.5]]);
    }

    function calendar(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        dc.drawRoundedRectangle(x - s * 0.45, y - s * 0.4, s * 0.9, s * 0.85, s * 0.08);
        dc.fillRectangle(x - s * 0.45, y - s * 0.4, s * 0.9, s * 0.24);
    }

    // Draws connected segments; points are fractions of s relative to (x, y).
    function polyline(dc as Dc, x as Numeric, y as Numeric, s as Numeric, pts as Array<Array<Float>>) as Void {
        for (var i = 1; i < pts.size(); i++) {
            var a = pts[i - 1];
            var b = pts[i];
            dc.drawLine(x + a[0] * s, y + a[1] * s, x + b[0] * s, y + b[1] * s);
        }
    }
}
