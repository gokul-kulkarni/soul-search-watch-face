import Toybox.Graphics;
import Toybox.Lang;

// Field -> icon. Solid glyph set (option A); all icons centre on (x, y) in a
// box of side s and take any colour. frac is the field's progress, used by
// icons that show a level (battery).
module Icons {

    function draw(dc as Dc, field as Number, x as Numeric, y as Numeric, s as Numeric, color as Number, frac as Float?) as Void {
        var cut = Theme.color(Theme.BG);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(Glyphs.pen(s));
        switch (field) {
            case Fields.HEART_RATE:    Glyphs.heart(dc, x, y, s); break;
            case Fields.BODY_BATTERY:  GlyphsBody.personBolt(dc, x, y, s, color, cut); break;
            case Fields.STRESS:        Glyphs.stress(dc, x, y, s, color, cut); break;
            case Fields.SLEEP_SCORE:   GlyphsBody.bed(dc, x, y, s); break;
            case Fields.PULSE_OX:      GlyphsBody.pulseOx(dc, x, y, s, color, cut); break;
            case Fields.RESPIRATION:   GlyphsBody.lungs(dc, x, y, s, color, cut); break;
            case Fields.RECOVERY:      GlyphsBody.recovery(dc, x, y, s, color, cut); break;
            case Fields.VO2MAX:        GlyphsBody.vo2(dc, x, y, s, color, cut); break;
            case Fields.STEPS:         Glyphs.steps(dc, x, y, s); break;
            case Fields.CALORIES:      GlyphsBody.flame(dc, x, y, s, color, cut); break;
            case Fields.FLOORS:        GlyphsBody.stairs(dc, x, y, s); break;
            case Fields.ACTIVE_MIN:    GlyphsBody.stopwatchBolt(dc, x, y, s, color, cut); break;
            case Fields.VIGOROUS:      GlyphsBody.vigorous(dc, x, y, s); break;
            case Fields.WEEKLY_RUN:    GlyphsBody.weeklyRun(dc, x, y, s, color, cut); break;
            case Fields.BATTERY:       Glyphs.battery(dc, x, y, s, color, cut, frac); break;
            case Fields.NOTIFICATIONS: Glyphs.bell(dc, x, y, s); break;
            case Fields.DATE:          Glyphs.calendar(dc, x, y, s, color, cut, false); break;
            case Fields.CALENDAR:      Glyphs.calendar(dc, x, y, s, color, cut, true); break;
            case Fields.TEMPERATURE:   GlyphsWeather.live(dc, x, y, s, color, cut); break;
            case Fields.FEELS_LIKE:    GlyphsWeather.feelsLike(dc, x, y, s); break;
            case Fields.WIND:          GlyphsWeather.gusts(dc, x, y, s); break;
            case Fields.UV:            GlyphsWeather.sun(dc, x, y, s, color, cut, true); break;
            case Fields.HUMIDITY:      GlyphsWeather.humidity(dc, x, y, s, color, cut); break;
            case Fields.PRECIP:        GlyphsWeather.rainCloud(dc, x, y, s); break;
            case Fields.SUN_EVENT:     GlyphsWeather.horizon(dc, x, y, s, Sun.isNextSunrise()); break;
            case Fields.SUNRISE:       GlyphsWeather.horizon(dc, x, y, s, true); break;
            case Fields.SUNSET:        GlyphsWeather.horizon(dc, x, y, s, false); break;
            case Fields.ALTITUDE:      GlyphsWeather.mountain(dc, x, y, s, color, cut); break;
        }
        dc.setPenWidth(1);
    }
}
