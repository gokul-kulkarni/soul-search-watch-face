import Toybox.Graphics;
import Toybox.Lang;

// Minimal: one-line HH:MM, a date above, one data line below, and the two
// lower arcs. Mostly black, so it is the most battery-friendly style.
// Uses the Bottom pod slot for the data line and the two bottom arc slots.
module StyleMinimal {

    const DATE_Y = -0.36;
    const DATA_Y = 0.3;
    const DIM_TEXT = 0x5E5E5E;

    function draw(dc as Dc) as Void {
        var r = Layout.r;
        StyleClassic.drawArcs(dc, [2, 3]);
        dc.setColor(Theme.tint(Theme.color(Theme.FG), 0.6), Graphics.COLOR_TRANSPARENT);
        dc.drawText(Layout.cx, Layout.cy + r * DATE_Y, Fonts.caption,
            Clock.weekday() + " " + Clock.dayOfMonth(), Text.CENTER);
        drawLineTime(dc, Layout.cx, Layout.cy, Theme.color(Theme.HOUR),
            Theme.color(Theme.ACCENT), Theme.color(Theme.MINUTE));
        StyleHud.inlineCell(dc, Settings.slots[Settings.POD_BOTTOM], Layout.cx, Layout.cy + r * DATA_Y);
    }

    // HH:MM on one line with separately coloured parts.
    function drawLineTime(dc as Dc, cx as Numeric, cy as Numeric,
                          hourColor as Number, colonColor as Number, minuteColor as Number) as Void {
        var p = Clock.stackedParts();
        var font = Fonts.time;
        var hw = dc.getTextWidthInPixels(p[0], font);
        var cw = dc.getTextWidthInPixels(":", font);
        var mw = dc.getTextWidthInPixels(p[1], font);
        var x = cx - (hw + cw + mw) / 2;
        var just = Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER;
        dc.setColor(hourColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, cy, font, p[0], just);
        dc.setColor(colonColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x + hw, cy, font, ":", just);
        dc.setColor(minuteColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x + hw + cw, cy, font, p[1], just);
    }

    // Always-on keeps the data line too: dim time plus the field's value.
    function drawLowPower(dc as Dc) as Void {
        LowPower.clear(dc);
        var s = LowPower.shift();
        var p = Clock.stackedParts();
        dc.setColor(LowPower.HOUR_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(Layout.cx + s[0], Layout.cy + s[1], Fonts.aod, p[0] + ":" + p[1], Text.CENTER);
        var field = Settings.slots[Settings.POD_BOTTOM];
        if (field != Fields.NONE) {
            var n = Fields.numeric(field);
            dc.setColor(DIM_TEXT, Graphics.COLOR_TRANSPARENT);
            dc.drawText(Layout.cx + s[0], Layout.cy + s[1] + Layout.r * DATA_Y, Fonts.caption,
                FieldStyle.format(field, n), Text.CENTER);
        }
    }

    function centers() as Array<Array<Numeric>> {
        var out = [[Settings.POD_BOTTOM, Layout.cx, Layout.cy + Layout.r * DATA_Y]] as Array<Array<Numeric>>;
        out.addAll(StyleClassic.arcCenters([2, 3]));
        return out;
    }
}
