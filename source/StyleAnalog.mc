import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;

// Analog: 60-tick dial, four pods inside it, tapered hour and minute hands.
// No seconds hand, to save battery. Uses the four pod slots.
module StyleAnalog {

    const POD_DISTANCE = 0.5;
    const POD_RADIUS = 0.16;
    const TICK_OUTER = 0.97;
    const TICK_MINUTE = 0.92;
    const TICK_HOUR = 0.85;
    const HOUR_LEN = 0.5;
    const MINUTE_LEN = 0.8;
    const HOUR_WIDTH = 0.07;
    const MINUTE_WIDTH = 0.05;
    const TAIL = 0.1;
    const MINUTE_TICK_TINT = 0.35;

    function draw(dc as Dc) as Void {
        drawTicks(dc);
        StyleClassic.drawPods(dc, POD_DISTANCE, POD_RADIUS);
        drawHands(dc, Theme.color(Theme.HOUR), Theme.color(Theme.MINUTE), Theme.color(Theme.ACCENT), true);
    }

    function drawTicks(dc as Dc) as Void {
        var r = Layout.r;
        var fg = Theme.color(Theme.FG);
        var minuteTick = Theme.tint(fg, MINUTE_TICK_TINT);
        for (var i = 0; i < 60; i++) {
            var hour = i % 5 == 0;
            var deg = 90 - i * 6;
            dc.setPenWidth(hour ? (r * 0.025).toNumber() : 2);
            dc.setColor(hour ? (i == 0 ? Theme.color(Theme.ACCENT) : fg) : minuteTick, Graphics.COLOR_TRANSPARENT);
            var inner = r * (hour ? TICK_HOUR : TICK_MINUTE);
            dc.drawLine(Geometry.x(Layout.cx, inner, deg), Geometry.y(Layout.cy, inner, deg),
                Geometry.x(Layout.cx, r * TICK_OUTER, deg), Geometry.y(Layout.cy, r * TICK_OUTER, deg));
        }
        dc.setPenWidth(1);
    }

    // Hands with a thin background outline so they separate from what is beneath.
    function drawHands(dc as Dc, hourColor as Number, minuteColor as Number, capColor as Number, outline as Boolean) as Void {
        var t = System.getClockTime();
        var minuteDeg = t.min * 6.0;
        var hourDeg = (t.hour % 12) * 30.0 + t.min * 0.5;
        var r = Layout.r;
        var bg = Theme.color(Theme.BG);
        if (outline) {
            hand(dc, hourDeg, r * (HOUR_LEN + 0.02), r * (HOUR_WIDTH + 0.03), r * (TAIL + 0.02), bg);
        }
        hand(dc, hourDeg, r * HOUR_LEN, r * HOUR_WIDTH, r * TAIL, hourColor);
        if (outline) {
            hand(dc, minuteDeg, r * (MINUTE_LEN + 0.02), r * (MINUTE_WIDTH + 0.03), r * (TAIL + 0.02), bg);
        }
        hand(dc, minuteDeg, r * MINUTE_LEN, r * MINUTE_WIDTH, r * TAIL, minuteColor);
        dc.setColor(capColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(Layout.cx, Layout.cy, r * 0.045);
        dc.setColor(bg, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(Layout.cx, Layout.cy, r * 0.018);
    }

    // Tapered hand at deg (clockwise from 12): wide at the hub, narrow at the tip.
    function hand(dc as Dc, deg as Float, length as Numeric, width as Numeric, tail as Numeric, color as Number) as Void {
        var a = Math.toRadians(deg);
        var dx = Math.sin(a);
        var dy = -Math.cos(a);
        var px = -dy;
        var py = dx;
        var cx = Layout.cx;
        var cy = Layout.cy;
        var hw = width / 2;
        var tw = width * 0.18;
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
}
