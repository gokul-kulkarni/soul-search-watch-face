import Toybox.Graphics;
import Toybox.Lang;

// Overlap: poster-sized digits. Hours sit behind in a dimmer shade, shifted
// up-left; bright minutes sit in front, shifted down-right, so the overlap
// reads as deliberate layering. Framed by the four arc gauges.
module StyleOverlap {

    const SHIFT_X = 0.13;     // fraction of radius
    const SHIFT_Y = 0.17;
    const HOUR_DIM = 0.45;    // how far the hours fade toward the background

    function draw(dc as Dc) as Void {
        StyleClassic.drawArcs(dc, [0, 1, 2, 3]);
        var scale = TimeSize.font() / TimeSize.FONT[0];
        var dx = Layout.r * SHIFT_X * scale;
        var dy = Layout.r * SHIFT_Y * scale;
        var p = Clock.stackedParts();
        var hour = Colors.blend(Theme.color(Theme.HOUR), Theme.color(Theme.BG), HOUR_DIM);
        dc.setColor(hour, Graphics.COLOR_TRANSPARENT);
        dc.drawText(Layout.cx - dx, Layout.cy - dy, Fonts.time, p[0], Text.CENTER);
        dc.setColor(Theme.color(Theme.MINUTE), Graphics.COLOR_TRANSPARENT);
        dc.drawText(Layout.cx + dx, Layout.cy + dy, Fonts.time, p[1], Text.CENTER);
    }
}
