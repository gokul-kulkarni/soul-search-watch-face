import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;

// Shared always-on helpers for AMOLED. Garmin blanks the screen if more than
// ~10% of pixels are lit or the same pixels stay lit too long, so always-on
// views draw small and dim on black, nudged a little every minute.
module LowPower {

    const HOUR_COLOR = 0x8C8C8C;
    const MINUTE_COLOR = 0x5E5E5E;
    const DIM = 0x4A4A4A;
    const SHIFT_RATIO = 0.04;
    const OFFSET_RATIO = 0.15;

    function clear(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
    }

    // Per-minute nudge, cycling through a 3x3 grid: [dx, dy].
    function shift() as Array<Numeric> {
        var min = System.getClockTime().min;
        var step = Layout.r * SHIFT_RATIO;
        return [((min % 3) - 1) * step, (((min / 3) % 3) - 1) * step];
    }

    // Dim stacked clock, used by the digital styles and as the crash fallback.
    function drawStacked(dc as Dc) as Void {
        clear(dc);
        var s = shift();
        var x = Layout.cx + s[0];
        var y = Layout.cy + s[1];
        var offset = Layout.r * OFFSET_RATIO;
        var p = Clock.stackedParts();
        dc.setColor(HOUR_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y - offset, Fonts.aod, p[0], Text.CENTER);
        dc.setColor(MINUTE_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y + offset, Fonts.aod, p[1], Text.CENTER);
    }
}
