import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

// Diagonal bezel gauge: tinted track + progress arc, the value set along the
// curve, and the icon just inside the value.
module Gauge {

    const ARC_INSET = 0.075;   // arc radius = R * (1 - ARC_INSET)
    const TEXT_INSET = 0.24;   // value radius = R * (1 - TEXT_INSET)
    const ICON_RATIO = 0.11;
    const ICON_INSET = 0.15;   // icon radius = value radius - this

    // spec: [fill start angle, direction (+1 ccw / -1 cw)].
    function draw(dc as Dc, field as Number, spec as Array<Number>) as Void {
        if (field == Fields.NONE) {
            return;
        }
        var start = spec[0];
        var dir = spec[1];
        var span = Layout.arcSpan();
        var radius = Layout.r;
        var r = radius * (1 - ARC_INSET);
        var pen = (radius * Style.arcPenRatio()).toNumber();

        var n = Fields.numeric(field);
        var frac = FieldStyle.progress(field, n);
        var color = FieldStyle.tint(field, n);

        arc(dc, Layout.cx, Layout.cy, r, pen, start, start + dir * span, dir, Theme.tint(color, Theme.TRACK_TINT));
        if (frac != null && frac > 0.0) {
            gradArc(dc, Layout.cx, Layout.cy, r, pen, start, start + dir * span * frac, color);
        }

        // Icon just inside the value, on the arc's middle angle.
        var iconDeg = start + dir * span / 2;
        var ir = radius * (1 - TEXT_INSET - ICON_INSET);
        Icons.draw(dc, field, Geometry.x(Layout.cx, ir, iconDeg), Geometry.y(Layout.cy, ir, iconDeg),
            radius * ICON_RATIO, color, frac);

        label(dc, radius * (1 - TEXT_INSET), start + dir * span / 2, FieldStyle.format(field, n));
    }

    // Smooth native arc with clean flat ends. Round caps were dropped: the
    // device strokes thick arcs at angle-dependent offsets, so added caps never
    // sit flush, and polygon-built arcs look faceted at this size.
    function arc(dc as Dc, cx as Numeric, cy as Numeric, r as Numeric, pen as Number, from as Numeric, to as Numeric,
                 dir as Number, color as Number) as Void {
        if (from.toNumber() == to.toNumber()) {
            return;
        }
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(pen);
        dc.drawArc(cx, cy, r, dir > 0 ? Graphics.ARC_COUNTER_CLOCKWISE : Graphics.ARC_CLOCKWISE, from, to);
        dc.setPenWidth(1);
    }

    // Progress arc whose colour runs along a ramp around the field colour.
    function gradArc(dc as Dc, cx as Numeric, cy as Numeric, r as Numeric, pen as Number,
                     from as Numeric, to as Numeric, color as Number) as Void {
        Grad.arc(dc, cx, cy, r, pen, from, to, Grad.ramp(color));
    }

    // Full smooth ring.
    function ring(dc as Dc, cx as Numeric, cy as Numeric, r as Numeric, pen as Number, color as Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(pen);
        dc.drawCircle(cx, cy, r);
        dc.setPenWidth(1);
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
