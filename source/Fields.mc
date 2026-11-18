import Toybox.Complications;
import Toybox.Lang;
import Toybox.System;

// The field catalogue: ids, menu names, one raw read per field, and the Garmin
// app each field opens on long-press. Formatting and colour live in FieldStyle.
module Fields {

    const NONE = 0;
    const HEART_RATE = 1;
    const STEPS = 2;
    const BATTERY = 3;
    const BODY_BATTERY = 4;
    const STRESS = 5;
    const CALORIES = 6;
    const FLOORS = 7;
    const ACTIVE_MIN = 8;
    const NOTIFICATIONS = 9;
    const TEMPERATURE = 10;
    const SUN_EVENT = 11;
    const RECOVERY = 12;
    const DATE = 13;
    const SLEEP_SCORE = 14;
    const VO2MAX = 15;
    const PULSE_OX = 16;
    const WIND = 17;
    const UV = 18;
    const HUMIDITY = 19;
    const PRECIP = 20;
    const FEELS_LIKE = 21;
    const SUNRISE = 22;
    const SUNSET = 23;
    const RESPIRATION = 24;
    const WEEKLY_RUN = 25;
    const ALTITUDE = 26;
    const CALENDAR = 27;
    const VIGOROUS = 28;
    const COUNT = 29;

    const PLACEHOLDER = "--";

    const NAMES = [
        "None", "Heart rate", "Steps", "Battery", "Body Battery", "Stress",
        "Calories", "Floors", "Intensity min (wk)", "Notifications",
        "Temperature", "Next sun event", "Recovery", "Date",
        "Sleep score", "VO2 max", "Pulse Ox", "Wind", "UV index", "Humidity",
        "Rain chance", "Feels like", "Sunrise", "Sunset", "Respiration",
        "Weekly run", "Altitude", "Calendar", "Vigorous min (wk)"
    ] as Array<String>;

    // Compact labels for labelled cells (HUD), indexed by field id.
    const SHORT = [
        "", "HR", "STEPS", "BATT", "BODY", "STRESS",
        "KCAL", "FLOORS", "INTENS", "NOTIF",
        "TEMP", "SUN", "RECOV", "DATE",
        "SLEEP", "VO2", "SPO2", "WIND", "UV", "HUMID",
        "RAIN", "FEELS", "RISE", "SET", "RESP",
        "RUN", "ALT", "CAL", "VIG"
    ] as Array<String>;

    // Picker order: grouped health, activity, watch, weather/outdoor.
    const MENU_ORDER = [
        NONE,
        HEART_RATE, BODY_BATTERY, STRESS, SLEEP_SCORE, PULSE_OX, RESPIRATION, RECOVERY, VO2MAX,
        STEPS, CALORIES, FLOORS, ACTIVE_MIN, VIGOROUS, WEEKLY_RUN,
        BATTERY, NOTIFICATIONS, DATE, CALENDAR,
        TEMPERATURE, FEELS_LIKE, WIND, UV, HUMIDITY, PRECIP, SUN_EVENT, SUNRISE, SUNSET, ALTITUDE
    ] as Array<Number>;

    // Each field's own colour, used when "Field colours" is on.
    const SIGNATURE = [
        0xFFFFFF, 0xFF4D6D, 0xFF9F1C, 0x34C759, 0x3FA9F5, 0xFFC93C,
        0xFF6B35, 0xB388FF, 0xFFB13C, 0x4FC3F7,
        0xFF8A65, 0xFFD54F, 0x64D8CB, 0xFFFFFF,
        0x9B7BFF, 0x00E5A0, 0x4DD0E1, 0x7FDBFF, 0xFFD60A, 0x4FC3F7,
        0x5C9DFF, 0xFF8A65, 0xFFB74D, 0xFF7043, 0x80DEEA,
        0xFF9F1C, 0xA5D6A7, 0xE57CFF, 0xFF5252
    ] as Array<Number>;

    // Garmin app opened by long-press, per field (null = nothing to open).
    const APPS = [
        null,
        Complications.COMPLICATION_TYPE_HEART_RATE,
        Complications.COMPLICATION_TYPE_STEPS,
        Complications.COMPLICATION_TYPE_BATTERY,
        Complications.COMPLICATION_TYPE_BODY_BATTERY,
        Complications.COMPLICATION_TYPE_STRESS,
        Complications.COMPLICATION_TYPE_CALORIES,
        Complications.COMPLICATION_TYPE_FLOORS_CLIMBED,
        Complications.COMPLICATION_TYPE_INTENSITY_MINUTES,
        Complications.COMPLICATION_TYPE_NOTIFICATION_COUNT,
        Complications.COMPLICATION_TYPE_CURRENT_WEATHER,
        Complications.COMPLICATION_TYPE_SUNRISE,
        Complications.COMPLICATION_TYPE_RECOVERY_TIME,
        Complications.COMPLICATION_TYPE_CALENDAR_EVENTS,
        Complications.COMPLICATION_TYPE_SLEEP_SCORE,
        Complications.COMPLICATION_TYPE_VO2MAX_RUN,
        Complications.COMPLICATION_TYPE_PULSE_OX,
        Complications.COMPLICATION_TYPE_CURRENT_WEATHER,
        Complications.COMPLICATION_TYPE_CURRENT_WEATHER,
        Complications.COMPLICATION_TYPE_CURRENT_WEATHER,
        Complications.COMPLICATION_TYPE_CURRENT_WEATHER,
        Complications.COMPLICATION_TYPE_CURRENT_WEATHER,
        Complications.COMPLICATION_TYPE_SUNRISE,
        Complications.COMPLICATION_TYPE_SUNSET,
        Complications.COMPLICATION_TYPE_RESPIRATION_RATE,
        Complications.COMPLICATION_TYPE_WEEKLY_RUN_DISTANCE,
        Complications.COMPLICATION_TYPE_ALTITUDE,
        Complications.COMPLICATION_TYPE_CALENDAR_EVENTS,
        Complications.COMPLICATION_TYPE_INTENSITY_MINUTES
    ] as Array<Complications.Type?>;

    function name(id as Number) as String {
        return NAMES[id];
    }

    function app(id as Number) as Complications.Type? {
        return APPS[id];
    }

    // One read per field per frame; FieldStyle derives text/progress/colour from it.
    function numeric(id as Number) as Number? {
        switch (id) {
            case HEART_RATE:    return Sensors.heartRate();
            case STEPS:         return Sensors.activityNumber(:steps);
            case BATTERY:       return Sensors.battery();
            case BODY_BATTERY:  return Sensors.bodyBattery();
            case STRESS:        return Sensors.stress();
            case CALORIES:      return Sensors.activityNumber(:calories);
            case FLOORS:        return Sensors.activityNumber(:floorsClimbed);
            case ACTIVE_MIN:    return Sensors.activeMinutesWeek(:total);
            case VIGOROUS:      return Sensors.activeMinutesWeek(:vigorous);
            case NOTIFICATIONS: return System.getDeviceSettings().notificationCount;
            case TEMPERATURE:   return Sun.temperature();
            case RECOVERY:      return Sensors.recoveryHours();
            case WIND:          return WeatherData.windKmh();
            case UV:            return WeatherData.uvIndex();
            case HUMIDITY:      return WeatherData.humidity();
            case PRECIP:        return WeatherData.precipitation();
            case FEELS_LIKE:    return WeatherData.feelsLike();
        }
        return complicationNumber(id);
    }

    // Fields whose only source is a Garmin complication.
    function complicationNumber(id as Number) as Number? {
        if (id == SLEEP_SCORE || id == VO2MAX || id == PULSE_OX
                || id == RESPIRATION || id == ALTITUDE) {
            return Complic.number(APPS[id] as Complications.Type);
        }
        return null;
    }
}
