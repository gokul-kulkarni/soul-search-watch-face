import Toybox.Graphics;
import Toybox.Lang;

// Watch-dial furniture shared by Serif and Analog: minute track and hour marks.
// Radii are fractions of the screen radius.
module Dial {

    // 60 short ticks between inner and outer.
    function minuteTrack(dc as Dc, inner as Float, outer as Float, color as Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        for (var i = 0; i < 60; i++) {
            if (i % 5 != 0) {
                tick(dc, 90 - i * 6, inner, outer);
            }
        }
    }

    // 12 hour marks; hours listed in skip are left out. 12 o'clock uses accent.
    function hourMarks(dc as Dc, inner as Float, outer as Float, pen as Number,
                       color as Number, accent as Number, skip as Array<Number>) as Void {
        dc.setPenWidth(pen);
        for (var h = 0; h < 12; h++) {
            if (skip.indexOf(h) >= 0) {
                continue;
            }
            dc.setColor(h == 0 ? accent : color, Graphics.COLOR_TRANSPARENT);
            tick(dc, 90 - h * 30, inner, outer);
        }
        dc.setPenWidth(1);
    }

    function tick(dc as Dc, deg as Numeric, inner as Float, outer as Float) as Void {
        var r = Layout.r;
        dc.drawLine(Geometry.x(Layout.cx, r * inner, deg), Geometry.y(Layout.cy, r * inner, deg),
            Geometry.x(Layout.cx, r * outer, deg), Geometry.y(Layout.cy, r * outer, deg));
    }
}
