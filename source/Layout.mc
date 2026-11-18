import Toybox.Lang;
import Toybox.Math;

// Where every slot sits. Shared by drawing and long-press hit-testing so the
// tap targets always match what is on screen. Fractions are of screen radius.
module Layout {

    const POD_DISTANCE = 0.76;   // pods sit at the edge, between the arcs
    const POD_RADIUS = 0.17;
    // Per pod: x direction, y direction, outward angle of its frame.
    const POD_DIRS = [[0, -1, 90], [-1, 0, 180], [1, 0, 0], [0, 1, 270]] as Array<Array<Number>>;

    // Per arc: [fill start angle, direction (+1 ccw / -1 cw), icon angle].
    // Every arc fills upward: top arcs rise toward 12 o'clock, bottom arcs rise
    // from near 6 o'clock toward 9 / 3. Icons sit at the vertical end.
    const ARC_SPECS = [
        [166, -1, 111],
        [14, 1, 69],
        [240, -1, 249],
        [300, 1, 291]
    ] as Array<Array<Number>>;
    const ARC_TARGET_RADIUS = 0.84;
    const HIT_RADIUS = 0.24;

    var cx as Number = 0;
    var cy as Number = 0;
    var r as Number = 0;

    function init(width as Number, height as Number) as Void {
        cx = width / 2;
        cy = height / 2;
        r = width / 2;
    }

    // Pod centre at a given distance from the middle (fraction of radius).
    function podX(i as Number, distance as Float) as Numeric {
        return cx + POD_DIRS[i][0] * r * distance;
    }

    function podY(i as Number, distance as Float) as Numeric {
        return cy + POD_DIRS[i][1] * r * distance;
    }

    function podOutward(i as Number) as Number {
        return POD_DIRS[i][2];
    }

    function arcMid(i as Number) as Number {
        return ARC_SPECS[i][0] + ARC_SPECS[i][1] * Gauge.SPAN / 2;
    }

    // Slot under a touch point, or null if none is close. Positions come from
    // the active style, so tap targets always match what is drawn.
    function slotAt(x as Numeric, y as Numeric) as Number? {
        var best = null;
        var bestDist = r * HIT_RADIUS;
        var centers = Style.slotCenters();
        for (var i = 0; i < centers.size(); i++) {
            var c = centers[i];
            var d = distance(x, y, c[1], c[2]);
            if (d < bestDist) {
                best = c[0].toNumber();
                bestDist = d;
            }
        }
        return best;
    }

    // Hit target for arc i (0-3): a point on the arc's middle.
    function arcTarget(i as Number) as Array<Numeric> {
        var deg = arcMid(i);
        return [Geometry.x(cx, r * ARC_TARGET_RADIUS, deg), Geometry.y(cy, r * ARC_TARGET_RADIUS, deg)];
    }

    function distance(x1 as Numeric, y1 as Numeric, x2 as Numeric, y2 as Numeric) as Float {
        var dx = (x1 - x2).toFloat();
        var dy = (y1 - y2).toFloat();
        return Math.sqrt(dx * dx + dy * dy).toFloat();
    }
}
