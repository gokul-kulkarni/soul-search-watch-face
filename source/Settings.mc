import Toybox.Application;
import Toybox.Lang;

// User preferences, persisted in on-device Storage. Every option is an index
// into a list; Options describes each list.
module Settings {

    // Slot order: 4 pods, then 4 arc gauges.
    const POD_TOP = 0;
    const POD_LEFT = 1;
    const POD_RIGHT = 2;
    const POD_BOTTOM = 3;
    const ARC_TL = 4;
    const SLOT_COUNT = 8;

    const SLOT_KEYS = [
        "podTop", "podLeft", "podRight", "podBottom",
        "arcTL", "arcTR", "arcBL", "arcBR"
    ] as Array<String>;
    const SLOT_DEFAULTS = [
        Fields.BATTERY, Fields.SUN_EVENT, Fields.DATE, Fields.NOTIFICATIONS,
        Fields.STEPS, Fields.BODY_BATTERY, Fields.SLEEP_SCORE, Fields.TEMPERATURE
    ] as Array<Number>;

    const KEY_STYLE = "style";
    const KEY_THEME = "theme";
    const KEY_DYNAMIC = "dynamic";
    const KEY_TIME_SIZE = "timeSize";
    const KEY_HOUR_COLOR = "hourColor";
    const KEY_MINUTE_COLOR = "minuteColor";
    const KEY_ACCENT_COLOR = "accentColor";
    const KEY_FIELD_COLORS = "fieldColors";

    var slots as Array<Number> = [0, 0, 0, 0, 0, 0, 0, 0] as Array<Number>;
    var style as Number = 0;
    var theme as Number = 0;
    var dynamic as Number = 1;
    var timeSize as Number = 0;
    var hourColor as Number = Palette.THEME;
    var minuteColor as Number = Palette.THEME;
    var accentColor as Number = Palette.THEME;
    var fieldColors as Number = 1;

    function reload() as Void {
        var fresh = new Array<Number>[SLOT_COUNT];
        for (var i = 0; i < SLOT_COUNT; i++) {
            fresh[i] = read(SLOT_KEYS[i], SLOT_DEFAULTS[i], Fields.COUNT);
        }
        slots = fresh;
        style = read(KEY_STYLE, 0, Style.count());
        theme = read(KEY_THEME, 0, Theme.count());
        dynamic = read(KEY_DYNAMIC, 1, 2);
        timeSize = read(KEY_TIME_SIZE, 0, TimeSize.count());
        hourColor = read(KEY_HOUR_COLOR, Palette.THEME, Palette.count());
        minuteColor = read(KEY_MINUTE_COLOR, Palette.THEME, Palette.count());
        accentColor = read(KEY_ACCENT_COLOR, Palette.THEME, Palette.count());
        fieldColors = read(KEY_FIELD_COLORS, 1, 2);
    }

    function useDynamicColors() as Boolean {
        return dynamic == 1;
    }

    function get(key as String) as Number {
        var slot = SLOT_KEYS.indexOf(key);
        if (slot >= 0) { return slots[slot]; }
        if (key.equals(KEY_STYLE)) { return style; }
        if (key.equals(KEY_THEME)) { return theme; }
        if (key.equals(KEY_DYNAMIC)) { return dynamic; }
        if (key.equals(KEY_TIME_SIZE)) { return timeSize; }
        if (key.equals(KEY_HOUR_COLOR)) { return hourColor; }
        if (key.equals(KEY_MINUTE_COLOR)) { return minuteColor; }
        if (key.equals(KEY_FIELD_COLORS)) { return fieldColors; }
        return accentColor;
    }

    function save(key as String, value as Number) as Void {
        Application.Storage.setValue(key, value);
        reload();
    }

    // Reads a stored option, falling back to the default if missing or out of range.
    function read(key as String, fallback as Number, count as Number) as Number {
        var v = Application.Storage.getValue(key);
        if (v instanceof Number && v >= 0 && v < count) {
            return v;
        }
        return fallback;
    }
}
