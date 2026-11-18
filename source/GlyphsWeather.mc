import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Weather;

// Weather and outdoor glyphs, plus the live condition icon. Same contract as Glyphs.
module GlyphsWeather {

    const CLEAR = 0;
    const PARTLY = 1;
    const CLOUDY = 2;
    const RAIN = 3;
    const SNOW = 4;
    const STORM = 5;
    const FOG = 6;

    // Live icon for the current conditions; a moon replaces the sun at night.
    function live(dc as Dc, x as Numeric, y as Numeric, s as Numeric, fg as Number, cut as Number) as Void {
        var kind = conditionKind();
        var night = Sun.isNight();
        switch (kind) {
            case PARTLY: if (night) { nightSky(dc, x, y, s, fg, cut); } else { partly(dc, x, y, s, fg, cut); } break;
            case CLOUDY: cloudy(dc, x, y, s, fg, cut); break;
            case RAIN:   rainCloud(dc, x, y, s); break;
            case SNOW:   snowCloud(dc, x, y, s); break;
            case STORM:  storm(dc, x, y, s, fg, cut); break;
            case FOG:    fog(dc, x, y, s); break;
            default:     if (night) { nightSky(dc, x, y, s, fg, cut); } else { sun(dc, x, y, s, fg, cut, false); } break;
        }
    }

    // Groups Garmin's 50+ conditions into the seven icons.
    function conditionKind() as Number {
        var c = Sun.conditions();
        if (c == null) { return CLEAR; }
        var cond = c.condition;
        if (cond == null) { return CLEAR; }
        switch (cond) {
            case Weather.CONDITION_PARTLY_CLOUDY:
            case Weather.CONDITION_PARTLY_CLEAR:
            case Weather.CONDITION_MOSTLY_CLEAR:
            case Weather.CONDITION_THIN_CLOUDS:
            case Weather.CONDITION_FAIR:
                return PARTLY;
            case Weather.CONDITION_CLOUDY:
            case Weather.CONDITION_MOSTLY_CLOUDY:
                return CLOUDY;
            case Weather.CONDITION_THUNDERSTORMS:
            case Weather.CONDITION_SCATTERED_THUNDERSTORMS:
            case Weather.CONDITION_CHANCE_OF_THUNDERSTORMS:
            case Weather.CONDITION_TROPICAL_STORM:
            case Weather.CONDITION_HURRICANE:
            case Weather.CONDITION_TORNADO:
            case Weather.CONDITION_SQUALL:
                return STORM;
            case Weather.CONDITION_SNOW:
            case Weather.CONDITION_LIGHT_SNOW:
            case Weather.CONDITION_HEAVY_SNOW:
            case Weather.CONDITION_FLURRIES:
            case Weather.CONDITION_CHANCE_OF_SNOW:
            case Weather.CONDITION_CLOUDY_CHANCE_OF_SNOW:
            case Weather.CONDITION_RAIN_SNOW:
            case Weather.CONDITION_LIGHT_RAIN_SNOW:
            case Weather.CONDITION_HEAVY_RAIN_SNOW:
            case Weather.CONDITION_CHANCE_OF_RAIN_SNOW:
            case Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN_SNOW:
            case Weather.CONDITION_WINTRY_MIX:
            case Weather.CONDITION_SLEET:
            case Weather.CONDITION_HAIL:
            case Weather.CONDITION_ICE:
            case Weather.CONDITION_ICE_SNOW:
            case Weather.CONDITION_FREEZING_RAIN:
                return SNOW;
            case Weather.CONDITION_RAIN:
            case Weather.CONDITION_LIGHT_RAIN:
            case Weather.CONDITION_HEAVY_RAIN:
            case Weather.CONDITION_DRIZZLE:
            case Weather.CONDITION_SHOWERS:
            case Weather.CONDITION_LIGHT_SHOWERS:
            case Weather.CONDITION_HEAVY_SHOWERS:
            case Weather.CONDITION_SCATTERED_SHOWERS:
            case Weather.CONDITION_CHANCE_OF_SHOWERS:
            case Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN:
            case Weather.CONDITION_UNKNOWN_PRECIPITATION:
                return RAIN;
            case Weather.CONDITION_FOG:
            case Weather.CONDITION_MIST:
            case Weather.CONDITION_HAZE:
            case Weather.CONDITION_HAZY:
            case Weather.CONDITION_SMOKE:
            case Weather.CONDITION_DUST:
            case Weather.CONDITION_SAND:
            case Weather.CONDITION_SANDSTORM:
            case Weather.CONDITION_VOLCANIC_ASH:
                return FOG;
        }
        return CLEAR;
    }

    // Sun: line rays for clear sky; bold triangular rays and a cut ring for UV.
    function sun(dc as Dc, x as Numeric, y as Numeric, s as Numeric, fg as Number, cut as Number, uv as Boolean) as Void {
        dc.fillCircle(x, y, s * 0.24);
        dc.setPenWidth(Glyphs.pen(s));
        for (var i = 0; i < 8; i++) {
            var a = Math.PI * i / 4;
            var c = Math.cos(a);
            var n = Math.sin(a);
            if (uv) {
                var p = Math.PI / 14;
                dc.fillPolygon([[x + c * s * 0.5, y + n * s * 0.5],
                    [x + Math.cos(a + p) * s * 0.31, y + Math.sin(a + p) * s * 0.31],
                    [x + Math.cos(a - p) * s * 0.31, y + Math.sin(a - p) * s * 0.31]]);
            } else {
                dc.drawLine(x + c * s * 0.34, y + n * s * 0.34, x + c * s * 0.49, y + n * s * 0.49);
            }
        }
        if (uv) {
            Glyphs.swap(dc, cut);
            var pw = Glyphs.pen(s) - 1;
            dc.setPenWidth(pw < 1 ? 1 : pw);
            dc.drawCircle(x, y, s * 0.14);
            Glyphs.swap(dc, fg);
        }
    }

    function nightSky(dc as Dc, x as Numeric, y as Numeric, s as Numeric, fg as Number, cut as Number) as Void {
        Glyphs.moon(dc, x - s * 0.06, y + s * 0.04, s * 0.9, fg, cut);
        dc.fillCircle(x + s * 0.3, y - s * 0.3, s * 0.07);
        dc.fillCircle(x + s * 0.4, y + s * 0.0, s * 0.05);
    }

    // Sun peeking behind a cloud; the cloud gets a cut-coloured rim.
    function partly(dc as Dc, x as Numeric, y as Numeric, s as Numeric, fg as Number, cut as Number) as Void {
        dc.fillCircle(x + s * 0.16, y - s * 0.16, s * 0.24);
        Glyphs.swap(dc, cut);
        Glyphs.cloud(dc, x - s * 0.04, y + s * 0.1, s * 1.12);
        Glyphs.swap(dc, fg);
        Glyphs.cloud(dc, x - s * 0.04, y + s * 0.1, s);
    }

    function cloudy(dc as Dc, x as Numeric, y as Numeric, s as Numeric, fg as Number, cut as Number) as Void {
        Glyphs.cloud(dc, x + s * 0.14, y - s * 0.12, s * 0.8);
        Glyphs.swap(dc, cut);
        Glyphs.cloud(dc, x - s * 0.06, y + s * 0.1, s * 1.12);
        Glyphs.swap(dc, fg);
        Glyphs.cloud(dc, x - s * 0.06, y + s * 0.1, s);
    }

    function rainCloud(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        Glyphs.cloud(dc, x, y - s * 0.12, s);
        for (var i = -1; i <= 1; i++) {
            Glyphs.poly(dc, x + i * s * 0.22, y, s, [[0.02, 0.24], [0.08, 0.24], [-0.02, 0.48], [-0.08, 0.48]]);
        }
    }

    function snowCloud(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        Glyphs.cloud(dc, x, y - s * 0.12, s);
        dc.fillCircle(x - s * 0.22, y + s * 0.32, s * 0.07);
        dc.fillCircle(x, y + s * 0.44, s * 0.07);
        dc.fillCircle(x + s * 0.22, y + s * 0.32, s * 0.07);
    }

    function storm(dc as Dc, x as Numeric, y as Numeric, s as Numeric, fg as Number, cut as Number) as Void {
        Glyphs.cloud(dc, x, y - s * 0.12, s);
        Glyphs.swap(dc, cut);
        Glyphs.poly(dc, x, y, s, [[0.08, 0.04], [-0.16, 0.3], [0.0, 0.3], [-0.08, 0.56], [0.2, 0.22], [0.04, 0.22], [0.14, 0.04]]);
        Glyphs.swap(dc, fg);
        Glyphs.poly(dc, x, y, s, [[0.06, 0.1], [-0.12, 0.3], [0.02, 0.3], [-0.05, 0.5], [0.16, 0.24], [0.02, 0.24], [0.1, 0.1]]);
    }

    function fog(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        dc.fillRoundedRectangle(x - s * 0.3, y - s * 0.36, s * 0.7, s * 0.14, s * 0.07);
        dc.fillRoundedRectangle(x - s * 0.48, y - s * 0.07, s * 0.96, s * 0.14, s * 0.07);
        dc.fillRoundedRectangle(x - s * 0.4, y + s * 0.22, s * 0.7, s * 0.14, s * 0.07);
    }

    function feelsLike(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        Glyphs.thermometer(dc, x - s * 0.16, y, s);
        dc.setPenWidth(Glyphs.pen(s));
        for (var i = 0; i < 2; i++) {
            var ox = x + s * (0.16 + i * 0.18);
            var pts = [[0.0, -0.36], [0.06, -0.24], [-0.04, -0.1], [0.06, 0.04], [-0.02, 0.16]];
            for (var k = 1; k < pts.size(); k++) {
                dc.drawLine(ox + pts[k - 1][0] * s, y + pts[k - 1][1] * s, ox + pts[k][0] * s, y + pts[k][1] * s);
            }
        }
    }

    // Wind: three gust lines with curled ends (direction is shown in the value).
    function gusts(dc as Dc, x as Numeric, y as Numeric, s as Numeric) as Void {
        var pw = (s * 0.1).toNumber();
        dc.setPenWidth(pw < 2 ? 2 : pw);
        dc.drawLine(x - s * 0.5, y - s * 0.2, x + s * 0.18, y - s * 0.2);
        dc.drawArc(x + s * 0.18, y - s * 0.32, s * 0.12, Graphics.ARC_COUNTER_CLOCKWISE, 270, 150);
        dc.drawLine(x - s * 0.5, y + s * 0.02, x + s * 0.34, y + s * 0.02);
        dc.drawArc(x + s * 0.34, y + s * 0.14, s * 0.12, Graphics.ARC_CLOCKWISE, 90, 210);
        dc.drawLine(x - s * 0.36, y + s * 0.24, x + s * 0.06, y + s * 0.24);
    }

    // Humidity: outlined drop filled to a level.
    function humidity(dc as Dc, x as Numeric, y as Numeric, s as Numeric, fg as Number, cut as Number) as Void {
        Glyphs.dropShape(dc, x, y, s);
        Glyphs.swap(dc, cut);
        Glyphs.dropShape(dc, x, y + s * 0.06, s * 0.74);
        Glyphs.swap(dc, fg);
        dc.setClip((x - s * 0.5).toNumber(), (y + s * 0.2).toNumber(), s.toNumber() + 1, (s * 0.5).toNumber());
        Glyphs.dropShape(dc, x, y + s * 0.06, s * 0.74);
        dc.clearClip();
    }

    // Half sun on the horizon with an arrow: up for sunrise, down for sunset.
    function horizon(dc as Dc, x as Numeric, y as Numeric, s as Numeric, rising as Boolean) as Void {
        var hy = y + s * 0.28;
        dc.setClip((x - s * 0.5).toNumber(), (y - s * 0.5).toNumber(), s.toNumber() + 1, (hy - (y - s * 0.5)).toNumber());
        dc.fillCircle(x, hy, s * 0.3);
        dc.clearClip();
        dc.fillRoundedRectangle(x - s * 0.5, hy + s * 0.04, s * 1.0, s * 0.1, s * 0.05);
        if (rising) {
            Glyphs.poly(dc, x, y, s, [[0.0, -0.54], [0.16, -0.34], [-0.16, -0.34]]);
        } else {
            Glyphs.poly(dc, x, y, s, [[0.0, -0.2], [0.16, -0.4], [-0.16, -0.4]]);
        }
    }

    function mountain(dc as Dc, x as Numeric, y as Numeric, s as Numeric, fg as Number, cut as Number) as Void {
        Glyphs.poly(dc, x, y, s, [[-0.5, 0.42], [-0.08, -0.4], [0.14, 0.02], [0.28, -0.18], [0.5, 0.42]]);
        Glyphs.swap(dc, cut);
        dc.setPenWidth(Glyphs.pen(s));
        dc.drawLine(x - s * 0.22, y - s * 0.12, x - s * 0.12, y - s * 0.04);
        dc.drawLine(x - s * 0.12, y - s * 0.04, x - s * 0.04, y - s * 0.14);
        dc.drawLine(x - s * 0.04, y - s * 0.14, x + s * 0.04, y - s * 0.06);
        Glyphs.swap(dc, fg);
    }
}
