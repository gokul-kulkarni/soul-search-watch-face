import Toybox.Graphics;
import Toybox.Lang;

// Serif: a classic dial. Large Pridi numerals stacked in the centre, a
// hairline ring with minute ticks and hour marks, and the four pod slots as
// plain text (small icon + value), no rings or arcs.
module StyleSerif {

    const RING = 0.975;
    const TOP_Y = 0.7;
    const SIDE_X = 0.64;
    const RING_TINT = 0.35;
    const MINUTE_TINT = 0.3;
    const HOUR_TINT = 0.75;

    function draw(dc as Dc) as Void {
        var fg = Theme.color(Theme.FG);
        dc.setColor(Theme.tint(fg, RING_TINT), Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawCircle(Layout.cx, Layout.cy, Layout.r * RING);
        Dial.minuteTrack(dc, 0.92, 0.955, Theme.tint(fg, MINUTE_TINT));
        Dial.hourMarks(dc, 0.87, 0.955, 2, Theme.tint(fg, HOUR_TINT), Theme.color(Theme.ACCENT), [] as Array<Number>);

        StyleClassic.drawStackedTime(dc, Layout.r * TimeSize.offset() * Style.timeScale());

        var c = centers();
        StyleHud.inlineCell(dc, Settings.slots[Settings.POD_TOP], c[0][1], c[0][2]);
        StyleHud.stackedCell(dc, Settings.slots[Settings.POD_LEFT], c[1][1], c[1][2]);
        StyleHud.stackedCell(dc, Settings.slots[Settings.POD_RIGHT], c[2][1], c[2][2]);
        StyleHud.inlineCell(dc, Settings.slots[Settings.POD_BOTTOM], c[3][1], c[3][2]);
    }

    function centers() as Array<Array<Numeric>> {
        var r = Layout.r;
        return [
            [Settings.POD_TOP, Layout.cx, Layout.cy - r * TOP_Y],
            [Settings.POD_LEFT, Layout.cx - r * SIDE_X, Layout.cy],
            [Settings.POD_RIGHT, Layout.cx + r * SIDE_X, Layout.cy],
            [Settings.POD_BOTTOM, Layout.cx, Layout.cy + r * TOP_Y]
        ] as Array<Array<Numeric>>;
    }
}
