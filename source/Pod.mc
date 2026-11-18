import Toybox.Graphics;
import Toybox.Lang;

// A cardinal data pod: icon over value, framed by an arc open toward the centre.
// The frame carries a faint tint of the field's colour.
module Pod {

    const FRAME_HALF_SPAN = 110;
    const ICON_RATIO = 0.55;

    function draw(dc as Dc, field as Number, px as Numeric, py as Numeric, pr as Numeric, outwardDeg as Number) as Void {
        if (field == Fields.NONE) {
            return;
        }
        var n = Fields.numeric(field);
        var color = FieldStyle.tint(field, n);

        dc.setPenWidth(Style.framePen());
        dc.setColor(Theme.tint(color, Theme.FRAME_TINT), Graphics.COLOR_TRANSPARENT);
        dc.drawArc(px, py, pr, Graphics.ARC_COUNTER_CLOCKWISE,
            outwardDeg - FRAME_HALF_SPAN, outwardDeg + FRAME_HALF_SPAN);
        dc.setPenWidth(1);

        var topY = py - pr * 0.36;
        var valueY = py + pr * 0.30;
        if (field == Fields.DATE) {
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.drawText(px, topY, Fonts.caption, Clock.weekday(), Text.CENTER);
        } else {
            Icons.draw(dc, field, px, topY, pr * ICON_RATIO, color, FieldStyle.progress(field, n));
        }
        var text = FieldStyle.format(field, n);
        dc.setColor(Theme.color(Theme.FG), Graphics.COLOR_TRANSPARENT);
        dc.drawText(px, valueY, FieldStyle.fitFont(dc, text, pr * 1.7), text, Text.CENTER);
    }
}
