import Toybox.Graphics;
import Toybox.Lang;

// Overlap: poster-sized stacked digits, minutes overlapping the hours, framed
// by the four arc gauges. No pods, so the time owns the centre.
module StyleOverlap {

    const OFFSET = 0.2;   // line offset, fraction of radius; small enough to overlap

    function draw(dc as Dc) as Void {
        StyleClassic.drawArcs(dc, [0, 1, 2, 3]);
        StyleClassic.drawStackedTime(dc, Layout.r * OFFSET * TimeSize.font() / TimeSize.FONT[0], true);
    }
}
