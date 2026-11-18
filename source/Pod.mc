import Toybox.Graphics;
import Toybox.Lang;

// A cardinal data pod at the edge: icon over value on a soft disc tinted with
// the field's colour.
module Pod {

    const DISC_TINT = 0.16;   // how strongly the disc shows the field colour
    const ICON_RATIO = 0.55;

    function draw(dc as Dc, field as Number, px as Numeric, py as Numeric, pr as Numeric, outwardDeg as Number) as Void {
        if (field == Fields.NONE) {
            return;
        }
        var n = Fields.numeric(field);
        var color = FieldStyle.tint(field, n);

        dc.setColor(Theme.tint(color, DISC_TINT), Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(px, py, pr);

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
