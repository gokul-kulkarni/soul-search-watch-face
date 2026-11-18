import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;

// Analog chronograph: minute track, bar hour markers, two sub-dials at 3 and 9
// (Left/Right pod slots) with their own progress rings, a field line at 6
// (Bottom pod slot), and bold hands with a darker inset stripe. No seconds hand.
module StyleAnalog {

    const SUB_X = 0.45;
    const SUB_R = 0.21;
    const SUB_PEN = 0.025;
    const BOTTOM_Y = 0.5;
    const HOUR_LEN = 0.52;
    const MINUTE_LEN = 0.84;
    const HOUR_WIDTH = 0.1;
    const MINUTE_WIDTH = 0.072;
    const TAIL = 0.12;
    const STRIPE_SHADE = 0.45;
    const TRACK_TINT = 0.35;
    const SUB_TINT = 0.22;

    function draw(dc as Dc) as Void {
        var fg = Theme.color(Theme.FG);
        Dial.minuteTrack(dc, 0.93, 0.975, Theme.tint(fg, TRACK_TINT));
        Dial.hourMarks(dc, 0.8, 0.93, (Layout.r * 0.035).toNumber(), fg, Theme.color(Theme.ACCENT), [3, 9]);
        var c = centers();
        subDial(dc, Settings.slots[Settings.POD_LEFT], c[0][1], c[0][2]);
        subDial(dc, Settings.slots[Settings.POD_RIGHT], c[1][1], c[1][2]);
        StyleHud.inlineCell(dc, Settings.slots[Settings.POD_BOTTOM], c[2][1], c[2][2]);
        drawHands(dc, Theme.color(Theme.HOUR), Theme.color(Theme.MINUTE), Theme.color(Theme.ACCENT), true);
    }

    // Small dial: tinted track ring, progress arc from 12 o'clock, icon over value.
    function subDial(dc as Dc, field as Number, x as Numeric, y as Numeric) as Void {
        if (field == Fields.NONE) {
            return;
        }
        var r = Layout.r * SUB_R;
        var n = Fields.numeric(field);
        var color = FieldStyle.tint(field, n);
        var pen = (Layout.r * SUB_PEN).toNumber();
        Gauge.ring(dc, x, y, r, pen, Theme.tint(color, SUB_TINT));
        var frac = FieldStyle.progress(field, n);
        if (frac != null && frac > 0.0) {
            if (frac >= 1.0) {
                Gauge.ring(dc, x, y, r, pen, color);
            } else {
                Gauge.arc(dc, x, y, r, pen, 90, 90 - 360 * frac, -1, color);
            }
        }
        Icons.draw(dc, field, x, y - r * 0.4, Layout.r * 0.09, color, frac);
        var text = FieldStyle.format(field, n);
        dc.setColor(Theme.color(Theme.FG), Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y + r * 0.3, FieldStyle.fitFont(dc, text, r * 1.7), text, Text.CENTER);
    }

    // Bold tapered hands, each with a darker inset stripe; outlined against the dial.
    function drawHands(dc as Dc, hourColor as Number, minuteColor as Number, capColor as Number, rich as Boolean) as Void {
        var t = System.getClockTime();
        var minuteDeg = t.min * 6.0;
        var hourDeg = (t.hour % 12) * 30.0 + t.min * 0.5;
        var r = Layout.r;
        var bg = Theme.color(Theme.BG);
        drawHand(dc, hourDeg, r * HOUR_LEN, r * HOUR_WIDTH, hourColor, bg, rich);
        drawHand(dc, minuteDeg, r * MINUTE_LEN, r * MINUTE_WIDTH, minuteColor, bg, rich);
        dc.setColor(capColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(Layout.cx, Layout.cy, r * 0.05);
        dc.setColor(bg, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(Layout.cx, Layout.cy, r * 0.02);
    }

    function drawHand(dc as Dc, deg as Float, len as Numeric, width as Numeric, color as Number,
                      bg as Number, rich as Boolean) as Void {
        var r = Layout.r;
        if (rich) {
            hand(dc, deg, len + r * 0.02, width + r * 0.03, r * (TAIL + 0.02), bg);
        }
        hand(dc, deg, len, width, r * TAIL, color);
        if (rich) {
            hand(dc, deg, len * 0.88, width * 0.34, -len * 0.3, Colors.blend(color, bg, STRIPE_SHADE));
        }
    }

    // Tapered quad at deg (clockwise from 12) from -tail to length; narrow tip.
    function hand(dc as Dc, deg as Float, length as Numeric, width as Numeric, tail as Numeric,
                  color as Number) as Void {
        var a = Math.toRadians(deg);
        var dx = Math.sin(a);
        var dy = -Math.cos(a);
        var px = -dy;
        var py = dx;
        var cx = Layout.cx;
        var cy = Layout.cy;
        var hw = width / 2;
        var tw = width * 0.22;
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([
            [cx - dx * tail + px * hw, cy - dy * tail + py * hw],
            [cx + dx * length + px * tw, cy + dy * length + py * tw],
            [cx + dx * length - px * tw, cy + dy * length - py * tw],
            [cx - dx * tail - px * hw, cy - dy * tail - py * hw]
        ]);
    }

    // Always-on: dim hands and twelve hour dots, the dots nudged each minute.
    function drawLowPower(dc as Dc) as Void {
        LowPower.clear(dc);
        var s = LowPower.shift();
        var r = Layout.r;
        dc.setColor(LowPower.DIM, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < 12; i++) {
            var deg = 90 - i * 30;
            dc.fillCircle(Geometry.x(Layout.cx, r * 0.9, deg) + s[0], Geometry.y(Layout.cy, r * 0.9, deg) + s[1], r * 0.02);
        }
        drawHands(dc, LowPower.HOUR_COLOR, LowPower.MINUTE_COLOR, LowPower.DIM, false);
    }

    function centers() as Array<Array<Numeric>> {
        var r = Layout.r;
        return [
            [Settings.POD_LEFT, Layout.cx - r * SUB_X, Layout.cy],
            [Settings.POD_RIGHT, Layout.cx + r * SUB_X, Layout.cy],
            [Settings.POD_BOTTOM, Layout.cx, Layout.cy + r * BOTTOM_Y]
        ] as Array<Array<Numeric>>;
    }
}
