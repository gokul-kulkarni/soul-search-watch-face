import Toybox.Graphics;
import Toybox.Lang;

// Classic: 4 edge tabs joined by 4 gradient arcs, with overlapping time in the
// centre: outlined hours behind (up-left), bright gradient minutes in front.
// Also holds the arc/pod/time building blocks other styles reuse.
module StyleClassic {

    const SHIFT_X = 0.11;     // overlap offset of each line, fraction of radius at Large
    const SHIFT_Y = 0.14;
    const HOUR_DIM = 0.2;     // how far the outlined hours fade toward the background

    function draw(dc as Dc) as Void {
        drawArcs(dc, [0, 1, 2, 3]);
        drawPods(dc, Layout.POD_DISTANCE, Layout.POD_RADIUS);
        drawOverlapTime(dc);
    }

    // Arc gauges by index (0 TL, 1 TR, 2 BL, 3 BR), each showing its slot's field.
    function drawArcs(dc as Dc, which as Array<Number>) as Void {
        for (var i = 0; i < which.size(); i++) {
            var a = which[i];
            Gauge.draw(dc, Settings.slots[Settings.ARC_TL + a], Layout.arcSpec(a));
        }
    }

    function drawPods(dc as Dc, distance as Float, radius as Float) as Void {
        var pr = Layout.r * radius;
        for (var i = 0; i < Layout.POD_DIRS.size(); i++) {
            Pod.draw(dc, Settings.slots[i], Layout.podX(i, distance), Layout.podY(i, distance),
                pr, Layout.podOutward(i));
        }
    }

    // Hours behind as a faint outline, minutes in front with a gradient.
    function drawOverlapTime(dc as Dc) as Void {
        var scale = TimeSize.font() / TimeSize.FONT[0];
        var dx = Layout.r * SHIFT_X * scale;
        var dy = Layout.r * SHIFT_Y * scale;
        var p = Clock.stackedParts();
        var px = Style.timePx();
        var hour = Colors.blend(Theme.color(Theme.HOUR), Theme.color(Theme.BG), HOUR_DIM);
        Shine.text(dc, Layout.cx - dx, Layout.cy - dy, Fonts.time, p[0], Text.CENTER, px, [hour], true);
        Shine.text(dc, Layout.cx + dx, Layout.cy + dy, Fonts.time, p[1], Text.CENTER, px,
            Grad.ramp(Theme.color(Theme.MINUTE)), false);
    }

    // Hours over minutes, each with a gradient of its colour.
    function drawStackedTime(dc as Dc, offset as Numeric) as Void {
        var p = Clock.stackedParts();
        var px = Style.timePx();
        Shine.text(dc, Layout.cx, Layout.cy - offset, Fonts.time, p[0], Text.CENTER, px,
            Grad.ramp(Theme.color(Theme.HOUR)), false);
        Shine.text(dc, Layout.cx, Layout.cy + offset, Fonts.time, p[1], Text.CENTER, px,
            Grad.ramp(Theme.color(Theme.MINUTE)), false);
    }

    function podCenters(distance as Float) as Array<Array<Numeric>> {
        var out = [] as Array<Array<Numeric>>;
        for (var i = 0; i < 4; i++) {
            out.add([i, Layout.podX(i, distance), Layout.podY(i, distance)]);
        }
        return out;
    }

    function arcCenters(which as Array<Number>) as Array<Array<Numeric>> {
        var out = [] as Array<Array<Numeric>>;
        for (var i = 0; i < which.size(); i++) {
            var t = Layout.arcTarget(which[i]);
            out.add([Settings.ARC_TL + which[i], t[0], t[1]]);
        }
        return out;
    }
}
