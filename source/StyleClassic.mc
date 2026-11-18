import Toybox.Graphics;
import Toybox.Lang;

// Classic (and Serif, which shares this layout): 4 arcs, 4 pods, stacked time.
// Also holds the arc/pod/time building blocks other styles reuse.
module StyleClassic {

    function draw(dc as Dc) as Void {
        drawArcs(dc, [0, 1, 2, 3]);
        drawPods(dc, Layout.POD_DISTANCE, Layout.POD_RADIUS);
        drawStackedTime(dc, Layout.r * TimeSize.offset(), false);
    }

    // Arc gauges by index (0 TL, 1 TR, 2 BL, 3 BR), each showing its slot's field.
    function drawArcs(dc as Dc, which as Array<Number>) as Void {
        for (var i = 0; i < which.size(); i++) {
            var a = which[i];
            Gauge.draw(dc, Settings.slots[Settings.ARC_TL + a], Layout.ARC_SPECS[a]);
        }
    }

    function drawPods(dc as Dc, distance as Float, radius as Float) as Void {
        var pr = Layout.r * radius;
        for (var i = 0; i < Layout.POD_DIRS.size(); i++) {
            Pod.draw(dc, Settings.slots[i], Layout.podX(i, distance), Layout.podY(i, distance),
                pr, Layout.podOutward(i));
        }
    }

    // Hours over minutes. With halo, minutes get a background-coloured outline
    // so they stay legible where they overlap the hours.
    function drawStackedTime(dc as Dc, offset as Numeric, halo as Boolean) as Void {
        var p = Clock.stackedParts();
        var cx = Layout.cx;
        var cy = Layout.cy;
        dc.setColor(Theme.color(Theme.HOUR), Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - offset, Fonts.time, p[0], Text.CENTER);
        if (halo) {
            var h = (Layout.r * 0.02).toNumber() + 1;
            dc.setColor(Theme.color(Theme.BG), Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx - h, cy + offset, Fonts.time, p[1], Text.CENTER);
            dc.drawText(cx + h, cy + offset, Fonts.time, p[1], Text.CENTER);
            dc.drawText(cx, cy + offset - h, Fonts.time, p[1], Text.CENTER);
            dc.drawText(cx, cy + offset + h, Fonts.time, p[1], Text.CENTER);
        }
        dc.setColor(Theme.color(Theme.MINUTE), Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + offset, Fonts.time, p[1], Text.CENTER);
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
