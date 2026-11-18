import Toybox.Graphics;
import Toybox.Lang;

// HUD: seven-segment time between two rules, one field above, three below.
// Uses the Top pod slot above the time and Left/Right/Bottom pod slots in the row.
module StyleHud {

    const TIME_HEIGHT = 0.42;   // at Large; scaled by time size
    const RULE_HALF = 0.62;
    const TOP_Y = -0.43;
    const ROW_Y = 0.45;
    const ROW_SPACING = 0.5;
    const DATE_Y = -0.66;
    const OFF_TINT = 0.12;
    const RULE_TINT = 0.35;

    function draw(dc as Dc) as Void {
        var r = Layout.r;
        var cx = Layout.cx;
        var cy = Layout.cy;
        var h = r * TIME_HEIGHT * TimeSize.font() / TimeSize.FONT[0];
        var accent = Theme.color(Theme.ACCENT);

        dc.setColor(Theme.color(Theme.FG), Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + r * DATE_Y, Fonts.caption, Clock.weekday() + " " + Clock.dayOfMonth(), Text.CENTER);

        dc.setColor(Theme.tint(accent, RULE_TINT), Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        var ruleGap = h * 0.5 + r * 0.08;
        dc.drawLine(cx - r * RULE_HALF, cy - ruleGap, cx + r * RULE_HALF, cy - ruleGap);
        dc.drawLine(cx - r * RULE_HALF, cy + ruleGap, cx + r * RULE_HALF, cy + ruleGap);
        dc.setPenWidth(1);

        Segments.drawTime(dc, cx, cy, h, Theme.color(Theme.HOUR), Theme.color(Theme.MINUTE), accent,
            Theme.tint(Theme.color(Theme.MINUTE), OFF_TINT));

        inlineCell(dc, Settings.slots[Settings.POD_TOP], cx, cy + r * TOP_Y);
        var row = [Settings.POD_LEFT, Settings.POD_BOTTOM, Settings.POD_RIGHT] as Array<Number>;
        for (var i = 0; i < row.size(); i++) {
            stackedCell(dc, Settings.slots[row[i]], cx + (i - 1) * r * ROW_SPACING, cy + r * ROW_Y);
        }
    }

    // Icon and value side by side.
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

    // Icon over value.
    function stackedCell(dc as Dc, field as Number, x as Numeric, y as Numeric) as Void {
        if (field == Fields.NONE) {
            return;
        }
        var n = Fields.numeric(field);
        var s = Layout.r * 0.11;
        Icons.draw(dc, field, x, y - s * 0.75, s, FieldStyle.tint(field, n), FieldStyle.progress(field, n));
        dc.setColor(Theme.color(Theme.FG), Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y + s * 0.65, Fonts.value, FieldStyle.format(field, n), Text.CENTER);
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
