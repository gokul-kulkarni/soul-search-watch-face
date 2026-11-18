import Toybox.Graphics;
import Toybox.Lang;

// A cardinal data pod drawn as an edge tab: a filled half-circle growing out
// of the bezel, tinted with the field's colour. The arcs run from tab to tab.
// Top/bottom tabs show icon and value side by side; side tabs stack them.
module Pod {

    const DISC_TINT = 0.16;     // how strongly the tab shows the field colour
    const SIDE_INSET = 0.55;    // content centre, as a fraction of the tab radius in from the edge
    const TOP_INSET = 0.5;

    // (px, py) is the tab centre on the screen edge; pr its radius.
    function draw(dc as Dc, field as Number, px as Numeric, py as Numeric, pr as Numeric, outwardDeg as Number) as Void {
        if (field == Fields.NONE) {
            return;
        }
        var n = Fields.numeric(field);
        var color = FieldStyle.tint(field, n);
        dc.setColor(Theme.tint(color, DISC_TINT), Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(px, py, pr);   // the screen edge cuts it to a half-circle

        var dx = px - Layout.cx;
        var dy = py - Layout.cy;
        if (dy != 0) {
            StyleHud.inlineCell(dc, field, px, py + (dy > 0 ? -pr * TOP_INSET : pr * TOP_INSET));
            return;
        }
        var x = px + (dx > 0 ? -pr * SIDE_INSET : pr * SIDE_INSET);
        var topY = py - pr * 0.3;
        var valueY = py + pr * 0.24;
        if (field == Fields.DATE) {
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, topY, Fonts.caption, Clock.weekday(), Text.CENTER);
        } else {
            Icons.draw(dc, field, x, topY, Layout.r * 0.11, color, FieldStyle.progress(field, n));
        }
        var text = FieldStyle.format(field, n);
        dc.setColor(Theme.color(Theme.FG), Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, valueY, FieldStyle.fitFont(dc, text, pr * 1.1), text, Text.CENTER);
    }

    // Where the tab's content sits (for long-press hit-testing).
    function contentDistance() as Float {
        return 1.0 - Layout.POD_RADIUS * SIDE_INSET;
    }
}
