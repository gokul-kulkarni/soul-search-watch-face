import Toybox.Complications;
import Toybox.Lang;

// How each field reads: text, gauge fill and value-driven colour.
module FieldStyle {

    // Status colours for value-driven colouring.
    const RED = 0xFF3B30;
    const ORANGE = 0xFF9500;
    const YELLOW = 0xFFCC00;
    const GREEN = 0x34C759;
    const BLUE = 0x4FC3F7;

    function format(id as Number, n as Number?) as String {
        var text = textField(id);
        if (text != null) { return text; }
        if (n == null) { return Fields.PLACEHOLDER; }
        switch (id) {
            case Fields.STEPS:
            case Fields.CALORIES:      return compact(n);
            case Fields.BATTERY:
            case Fields.PULSE_OX:
            case Fields.HUMIDITY:
            case Fields.PRECIP:        return n.format("%d") + "%";
            case Fields.TEMPERATURE:
            case Fields.FEELS_LIKE:    return Sun.toUserUnits(n).format("%d") + "°";
            case Fields.RECOVERY:      return n.format("%d") + "h";
            case Fields.WIND:          return WeatherData.windForUser(n).format("%d");
        }
        return n.format("%d");
    }

    // Fields that are text rather than numbers; null for numeric fields.
    function textField(id as Number) as String? {
        switch (id) {
            case Fields.SUN_EVENT:  return Sun.nextEventText();
            case Fields.SUNRISE:    return Sun.eventText(true);
            case Fields.SUNSET:     return Sun.eventText(false);
            case Fields.DATE:       return Clock.dayOfMonth();
            case Fields.WEEKLY_RUN:
            case Fields.CALENDAR:
                var t = Complic.text(Fields.app(id) as Complications.Type);
                return t == null ? Fields.PLACEHOLDER : t;
        }
        return null;
    }

    // 12345 -> "12k", 1234 -> "1.2k"
    function compact(n as Number) as String {
        if (n >= 10000) { return (n / 1000).format("%d") + "k"; }
        if (n >= 1000) { return (n / 1000.0).format("%.1f") + "k"; }
        return n.format("%d");
    }

    // Gauge fill 0.0-1.0, or null when the field has no natural range.
    function progress(id as Number, n as Number?) as Float? {
        if (n == null) { return null; }
        switch (id) {
            case Fields.HEART_RATE:   return clamp((n - 40) / 140.0);
            case Fields.STEPS:        return ratio(n, Sensors.stepGoal());
            case Fields.FLOORS:       return ratio(n, Sensors.goal(:floorsClimbedGoal));
            case Fields.ACTIVE_MIN:   return ratio(n, Sensors.goal(:activeMinutesWeekGoal));
            case Fields.VIGOROUS:     return ratio(n * 2, Sensors.goal(:activeMinutesWeekGoal));
            case Fields.BATTERY:
            case Fields.BODY_BATTERY:
            case Fields.STRESS:
            case Fields.SLEEP_SCORE:
            case Fields.HUMIDITY:
            case Fields.PRECIP:       return clamp(n / 100.0);
            case Fields.TEMPERATURE:
            case Fields.FEELS_LIKE:   return clamp((n + 10) / 50.0);
            case Fields.RECOVERY:     return clamp(n / 72.0);
            case Fields.VO2MAX:       return clamp((n - 30) / 40.0);
            case Fields.PULSE_OX:     return clamp((n - 80) / 20.0);
            case Fields.UV:           return clamp(n / 11.0);
            case Fields.WIND:         return clamp(n / 50.0);
        }
        return null;
    }

    // The field's colour: value-driven if dynamic colours apply, else the
    // field's own colour or the accent. Always adapted to the background.
    function tint(id as Number, n as Number?) as Number {
        var c = null;
        if (n != null && Settings.useDynamicColors()) {
            c = rawColor(id, n);
        }
        if (c == null) {
            c = (Settings.fieldColors == 1 && id != Fields.DATE) ? Fields.SIGNATURE[id] : Theme.color(Theme.ACCENT);
        }
        return Theme.adapt(c);
    }

    function rawColor(id as Number, n as Number) as Number? {
        switch (id) {
            case Fields.BATTERY:      return n <= 15 ? RED : (n <= 30 ? ORANGE : GREEN);
            case Fields.BODY_BATTERY: return n <= 25 ? RED : (n <= 50 ? ORANGE : (n <= 75 ? YELLOW : BLUE));
            case Fields.STRESS:       return n <= 25 ? BLUE : (n <= 50 ? YELLOW : (n <= 75 ? ORANGE : RED));
            case Fields.HEART_RATE:   return n < 100 ? null : (n < 140 ? ORANGE : RED);
            case Fields.RECOVERY:     return n > 48 ? RED : (n > 24 ? ORANGE : GREEN);
            case Fields.SLEEP_SCORE:  return n < 60 ? RED : (n < 80 ? ORANGE : GREEN);
            case Fields.PULSE_OX:     return n < 90 ? RED : (n < 95 ? ORANGE : null);
            case Fields.UV:           return n <= 2 ? GREEN : (n <= 5 ? YELLOW : (n <= 7 ? ORANGE : RED));
            case Fields.PRECIP:       return n >= 60 ? BLUE : null;
            case Fields.TEMPERATURE:
            case Fields.FEELS_LIKE:   return n < 5 ? BLUE : (n < 28 ? null : (n < 34 ? ORANGE : RED));
        }
        return null;
    }

    function clamp(f as Float) as Float {
        return f < 0.0 ? 0.0 : (f > 1.0 ? 1.0 : f);
    }

    function ratio(n as Number, max as Number?) as Float? {
        if (max == null || max <= 0) { return null; }
        return clamp(n.toFloat() / max);
    }
}
