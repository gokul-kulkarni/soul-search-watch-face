import Toybox.Graphics;
import Toybox.Lang;

// HUD: an instrument panel. Seven-segment time with neutral unlit segments,
// one labelled cell above and three below, each outlined in its field's colour.
// Uses the Top pod slot above and Left/Bottom/Right pod slots in the row.
// Also hosts the small cell helpers other styles reuse.
module StyleHud {

    const TIME_HEIGHT = 0.42;   // at Large; scaled by time size
    const TOP_Y = -0.5;
    const TOP_W = 0.62;
    const ROW_Y = 0.47;
    const ROW_SPACING = 0.44;
    const CELL_W = 0.4;
    const CELL_H = 0.32;
    const GHOST_TINT = 0.1;
    const BOX_TINT = 0.45;

    function draw(dc as Dc) as Void {
        var r = Layout.r;
        var cx = Layout.cx;
        var cy = Layout.cy;
        var h = r * TIME_HEIGHT * TimeSize.font() / TimeSize.FONT[0];
        Segments.drawTime(dc, cx, cy - r * 0.02, h, Theme.color(Theme.HOUR), Theme.color(Theme.MINUTE),
            Theme.color(Theme.ACCENT), Theme.tint(Theme.color(Theme.FG), GHOST_TINT));

        var c = centers();
        boxCell(dc, Settings.slots[Settings.POD_TOP], c[0][1], c[0][2], r * TOP_W);
        for (var i = 1; i < c.size(); i++) {
            boxCell(dc, Settings.slots[c[i][0].toNumber()], c[i][1], c[i][2], r * CELL_W);
        }
    }

    // Outlined cell: short label in the field's colour over the value.
    function boxCell(dc as Dc, field as Number, x as Numeric, y as Numeric, w as Numeric) as Void {
        if (field == Fields.NONE) {
            return;
        }
        var r = Layout.r;
        var h = r * CELL_H;
        var n = Fields.numeric(field);
        var color = FieldStyle.tint(field, n);
        dc.setColor(Theme.tint(color, BOX_TINT), Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawRoundedRectangle(x - w / 2, y - h / 2, w, h, r * 0.05);
        dc.setPenWidth(1);

        // The date cell uses the weekday as its label so the value stays short.
        var label = field == Fields.DATE ? Clock.weekday() : Fields.SHORT[field];
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y - h * 0.22, Fonts.caption, label, Text.CENTER);
        var value = FieldStyle.format(field, n);
        dc.setColor(Theme.color(Theme.FG), Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y + h * 0.17, FieldStyle.fitFont(dc, value, w * 0.88), value, Text.CENTER);
    }

    // Icon and value side by side (used by Serif and Minimal).
    function inlineCell(dc as Dc, field as Number, x as Numeric, y as Numeric) as Void {
        if (field == Fields.NONE) {
            return;
        }
        var n = Fields.numeric(field);
        var text = FieldStyle.format(field, n);
        var s = Layout.r * 0.11;
        var tw = dc.getTextWidthInPixels(text, Fonts.value);
        var left = x - (s + s * 0.4 + tw) / 2;
        Icons.draw(dc, field, left + s / 2, y, s, FieldStyle.tint(field, n), FieldStyle.progress(field, n));
        dc.setColor(Theme.color(Theme.FG), Graphics.COLOR_TRANSPARENT);
        dc.drawText(left + s * 1.4, y, Fonts.value, text, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Icon over value (used by Serif).
    function stackedCell(dc as Dc, field as Number, x as Numeric, y as Numeric) as Void {
        if (field == Fields.NONE) {
            return;
        }
        var n = Fields.numeric(field);
        var s = Layout.r * 0.11;
        Icons.draw(dc, field, x, y - s * 0.75, s, FieldStyle.tint(field, n), FieldStyle.progress(field, n));
        var text = FieldStyle.format(field, n);
        dc.setColor(Theme.color(Theme.FG), Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y + s * 0.65, FieldStyle.fitFont(dc, text, Layout.r * 0.42), text, Text.CENTER);
    }

    function drawLowPower(dc as Dc) as Void {
        LowPower.clear(dc);
        var s = LowPower.shift();
        var h = Layout.r * TIME_HEIGHT * 0.8;
        Segments.drawTime(dc, Layout.cx + s[0], Layout.cy + s[1], h,
            LowPower.HOUR_COLOR, LowPower.MINUTE_COLOR, LowPower.DIM, null);
    }

    function centers() as Array<Array<Numeric>> {
        var r = Layout.r;
        var cx = Layout.cx;
        var cy = Layout.cy;
        return [
            [Settings.POD_TOP, cx, cy + r * TOP_Y],
            [Settings.POD_LEFT, cx - r * ROW_SPACING, cy + r * ROW_Y],
            [Settings.POD_BOTTOM, cx, cy + r * ROW_Y],
            [Settings.POD_RIGHT, cx + r * ROW_SPACING, cy + r * ROW_Y]
        ] as Array<Array<Numeric>>;
    }
}
