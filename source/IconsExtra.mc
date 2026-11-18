import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

// Icons for health-extra, weather and outdoor fields. Same contract as Icons:
// centred on (x, y), fitting a box of side s, colour already set on dc.
module IconsExtra {

    function dispatch(dc as Dc, field as Number, x as Numeric, y as Numeric, s as Numeric, color as Number) as Void {
        switch (field) {
            case Fields.SLEEP_SCORE: moon(dc, x, y, s, color); break;
            case Fields.VO2MAX:      lungs(dc, x, y, s); break;
            case Fields.PULSE_OX:    drop(dc, x, y, s, color, false); break;
            case Fields.HUMIDITY:    drop(dc, x, y, s, color, true); break;
            case Fields.WIND:        wind(dc, x, y, s); break;
            case Fields.UV:          uv(dc, x, y, s); break;
            case Fields.PRECIP:      cloudRain(dc, x, y, s); break;
            case Fields.FEELS_LIKE:  Icons.thermometer(dc, x, y, s); break;
            case Fields.SUNRISE:     horizonSun(dc, x, y, s, color, true); break;
            case Fields.SUNSET:      horizonSun(dc, x, y, s, color, false); break;
            case Fields.RESPIRATION: respiration(dc, x, y, s); break;
            case Fields.WEEKLY_RUN:  shoe(dc, x, y, s); break;
            case Fields.ALTITUDE:    mountain(dc, x, y, s); break;
            case Fields.VIGOROUS:    chevrons(dc, x, y, s); break;
        }
    }

    function moon(dc as Dc, x as Numeric, y as Numeric, s as Numeric, color as Number) as Void {
        dc.fillCircle(x, y, s * 0.42);
        dc.setColor(Theme.color(Theme.BG), Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x + s * 0.2, y - s * 0.16, s * 0.34);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
    }

    function lungs(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        dc.fillEllipse(x - s * 0.24, y + s * 0.1, s * 0.18, s * 0.34);
        dc.fillEllipse(x + s * 0.24, y + s * 0.1, s * 0.18, s * 0.34);
        dc.drawLine(x, y - s * 0.5, x, y - s * 0.12);
    }

    function drop(dc as Dc, x as Numeric, y as Numeric, s as Numeric, color as Number, hollow as Boolean) as Void {
        dc.fillCircle(x, y + s * 0.16, s * 0.3);
        dc.fillPolygon([[x, y - s * 0.5], [x + s * 0.27, y + s * 0.04], [x - s * 0.27, y + s * 0.04]]);
        if (hollow) {
            dc.setColor(Theme.color(Theme.BG), Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(x, y + s * 0.16, s * 0.16);
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        }
    }

    // Arrow pointing where the wind blows to; plain wind lines if no bearing.
    function wind(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        var bearing = WeatherData.windBearing();
        if (bearing == null) {
            respiration(dc, x, y, s);
            return;
        }
        var a = Math.toRadians(bearing + 180);
        var pts = [[0.0, -0.5], [0.32, 0.36], [0.0, 0.16], [-0.32, 0.36]];
        var poly = [];
        for (var i = 0; i < pts.size(); i++) {
            var px = pts[i][0] * s;
            var py = pts[i][1] * s;
            poly.add([x + px * Math.cos(a) - py * Math.sin(a), y + px * Math.sin(a) + py * Math.cos(a)]);
        }
        dc.fillPolygon(poly);
    }

    function uv(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        dc.drawCircle(x, y, s * 0.2);
        rays(dc, x, y, s, 8, 0.3);
    }

    function cloudRain(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        dc.fillCircle(x - s * 0.18, y - s * 0.12, s * 0.18);
        dc.fillCircle(x + s * 0.08, y - s * 0.2, s * 0.24);
        dc.fillRoundedRectangle(x - s * 0.42, y - s * 0.12, s * 0.84, s * 0.22, s * 0.11);
        for (var i = -1; i <= 1; i++) {
            var dx = x + i * s * 0.22;
            dc.drawLine(dx, y + s * 0.22, dx - s * 0.08, y + s * 0.46);
        }
    }

    // Half sun on a horizon with an up (sunrise) or down (sunset) arrow.
    function horizonSun(dc as Dc, x as Numeric, y as Numeric, s as Numeric, color as Number, rising as Boolean) as Void {
        var horizon = y + s * 0.3;
        dc.fillCircle(x, horizon, s * 0.26);
        dc.setColor(Theme.color(Theme.BG), Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x - s * 0.3, horizon + 1, s * 0.6, s * 0.3);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x - s * 0.5, horizon, x + s * 0.5, horizon);
        var tip = rising ? y - s * 0.5 : y - s * 0.12;
        var base = rising ? y - s * 0.22 : y - s * 0.4;
        dc.fillPolygon([[x, tip], [x + s * 0.14, base], [x - s * 0.14, base]]);
    }

    function respiration(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        dc.drawLine(x - s * 0.5, y - s * 0.25, x + s * 0.3, y - s * 0.25);
        dc.drawLine(x - s * 0.5, y, x + s * 0.5, y);
        dc.drawLine(x - s * 0.3, y + s * 0.25, x + s * 0.4, y + s * 0.25);
    }

    function shoe(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        var pts = [[-0.5, 0.3], [-0.5, -0.05], [-0.2, -0.05], [0.0, -0.35],
                   [0.2, -0.35], [0.16, 0.0], [0.5, 0.12], [0.5, 0.3]];
        dc.fillPolygon(scaled(x, y, s, pts));
    }

    // Two forward chevrons: hard effort.
    function chevrons(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        for (var i = 0; i < 2; i++) {
            var ox = x - s * 0.3 + i * s * 0.36;
            dc.fillPolygon([
                [ox, y - s * 0.42], [ox + s * 0.3, y], [ox, y + s * 0.42],
                [ox - s * 0.14, y + s * 0.42], [ox + s * 0.16, y], [ox - s * 0.14, y - s * 0.42]
            ]);
        }
    }

    function mountain(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        var pts = [[-0.5, 0.4], [-0.1, -0.35], [0.14, 0.04], [0.28, -0.16], [0.5, 0.4]];
        dc.fillPolygon(scaled(x, y, s, pts));
    }

    function rays(dc as Dc, x as Numeric, y as Numeric, s as Numeric, count as Number, inner as Float) as Void {
        for (var i = 0; i < count; i++) {
            var a = Math.PI * 2 * i / count;
            var c = Math.cos(a);
            var n = Math.sin(a);
            dc.drawLine(x + c * s * inner, y + n * s * inner, x + c * s * 0.48, y + n * s * 0.48);
        }
    }

    function scaled(x as Numeric, y as Numeric, s as Numeric, pts as Array<Array<Float>>) as Array<Graphics.Point2D> {
        var out = [] as Array<Graphics.Point2D>;
        for (var i = 0; i < pts.size(); i++) {
            out.add([x + pts[i][0] * s, y + pts[i][1] * s]);
        }
        return out;
    }
}
