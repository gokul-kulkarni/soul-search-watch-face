import Toybox.Graphics;
import Toybox.Lang;

// Minimal: a large one-line time as the hero, one thin progress ring around
// the whole bezel, and the date and one field as quiet text. Mostly black, so
// it is the most battery-friendly style. The ring shows the top-left arc slot;
// the text field is the Bottom pod slot.
module StyleMinimal {

    const RING = 0.955;
    const RING_PEN = 0.014;
    const TRACK_TINT = 0.18;
    const DATE_Y = -0.4;
    const DATA_Y = 0.4;
    const DATE_TINT = 0.55;
    const DIM_TEXT = 0x5E5E5E;

    function draw(dc as Dc) as Void {
        var r = Layout.r;
        drawRing(dc, Settings.slots[Settings.ARC_TL]);
        dc.setColor(Theme.tint(Theme.color(Theme.FG), DATE_TINT), Graphics.COLOR_TRANSPARENT);
        dc.drawText(Layout.cx, Layout.cy + r * DATE_Y, Fonts.caption,
            Clock.weekday() + " " + Clock.dayOfMonth(), Text.CENTER);
        drawLineTime(dc, Layout.cx, Layout.cy, Theme.color(Theme.HOUR),
            Theme.color(Theme.ACCENT), Theme.color(Theme.MINUTE));
        StyleHud.inlineCell(dc, Settings.slots[Settings.POD_BOTTOM], Layout.cx, Layout.cy + r * DATA_Y);
    }

    // Full-circle progress ring, filling clockwise from 12 o'clock.
    function drawRing(dc as Dc, field as Number) as Void {
        if (field == Fields.NONE) {
            return;
        }
        var r = Layout.r * RING;
        var pen = (Layout.r * RING_PEN).toNumber();
        var n = Fields.numeric(field);
        var color = FieldStyle.tint(field, n);
        Gauge.ring(dc, Layout.cx, Layout.cy, r, pen, Theme.tint(color, TRACK_TINT));
        var frac = FieldStyle.progress(field, n);
        if (frac != null && frac > 0.0) {
            if (frac >= 1.0) {
                Gauge.ring(dc, Layout.cx, Layout.cy, r, pen, color);
            } else {
                Gauge.arc(dc, Layout.cx, Layout.cy, r, pen, 90, 90 - 360 * frac, -1, color);
            }
        }
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
        var r = Layout.r;
        return [
            [Settings.POD_BOTTOM, Layout.cx, Layout.cy + r * DATA_Y],
            [Settings.ARC_TL, Layout.cx, Layout.cy - r * RING]
        ] as Array<Array<Numeric>>;
    }
}
