import Toybox.Graphics;
import Toybox.Lang;

// Diagonal bezel gauge: tinted track + progress arc with rounded caps, an icon
// at the arc's vertical end, and the value set along the curve.
module Gauge {

    const SPAN = 46;           // degrees of arc
    const ICON_GAP = 10;       // degrees between arc end and icon centre
    const ARC_INSET = 0.075;   // arc radius = R * (1 - ARC_INSET)
    const TEXT_INSET = 0.24;   // value radius = R * (1 - TEXT_INSET)
    const ICON_RATIO = 0.13;

    // spec: [fill start angle, direction (+1 ccw / -1 cw), icon angle].
    function draw(dc as Dc, field as Number, spec as Array<Number>) as Void {
        if (field == Fields.NONE) {
            return;
        }
        var start = spec[0];
        var dir = spec[1];
        var radius = Layout.r;
        var r = radius * (1 - ARC_INSET);
        var pen = (radius * Style.arcPenRatio()).toNumber();

        var n = Fields.numeric(field);
        var frac = FieldStyle.progress(field, n);
        var color = FieldStyle.tint(field, n);

        arc(dc, r, pen, start, start + dir * SPAN, dir, Theme.tint(color, Theme.TRACK_TINT));
        if (frac != null && frac > 0.0) {
            arc(dc, r, pen, start, start + dir * SPAN * frac, dir, color);
        }

        var iconDeg = spec[2];
        Icons.draw(dc, field, Geometry.x(Layout.cx, r, iconDeg), Geometry.y(Layout.cy, r, iconDeg),
            radius * ICON_RATIO, color, frac);

        label(dc, radius * (1 - TEXT_INSET), start + dir * SPAN / 2, FieldStyle.format(field, n));
    }

    function arc(dc as Dc, r as Numeric, pen as Number, from as Numeric, to as Numeric,
                 dir as Number, color as Number) as Void {
        var cx = Layout.cx;
        var cy = Layout.cy;
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(pen);
        var attr = dir > 0 ? Graphics.ARC_COUNTER_CLOCKWISE : Graphics.ARC_CLOCKWISE;
        if (from.toNumber() != to.toNumber()) {
            dc.drawArc(cx, cy, r, attr, from, to);
        }
        dc.setPenWidth(1);
        var cap = pen / 2;
        dc.fillCircle(Geometry.x(cx, r, from), Geometry.y(cy, r, from), cap);
        dc.fillCircle(Geometry.x(cx, r, to), Geometry.y(cy, r, to), cap);
    }

    // Text follows the curve; upper gauges read clockwise, lower ones counter-clockwise
    // so the value is never upside down.
    function label(dc as Dc, r as Numeric, deg as Numeric, text as String) as Void {
        var cx = Layout.cx;
        var cy = Layout.cy;
        dc.setColor(Theme.color(Theme.FG), Graphics.COLOR_TRANSPARENT);
        var font = Fonts.radial;
        var upper = Geometry.y(cy, r, deg) < cy;
        if (font != null && (Graphics.Dc has :drawRadialText)) {
            var direction = upper
                ? Graphics.RADIAL_TEXT_DIRECTION_CLOCKWISE
                : Graphics.RADIAL_TEXT_DIRECTION_COUNTER_CLOCKWISE;
            dc.drawRadialText(cx, cy, font, text, Text.CENTER, deg, r, direction);
        } else {
            dc.drawText(Geometry.x(cx, r, deg), Geometry.y(cy, r, deg), Fonts.caption, text, Text.CENTER);
        }
    }
}
