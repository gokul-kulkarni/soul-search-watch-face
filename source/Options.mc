import Toybox.Lang;

// Describes each setting's list of choices, for the menus.
module Options {

    const KIND_FIELD = 0;
    const KIND_COLOR = 1;
    const KIND_LIST = 2;

    const ON_OFF = ["Off", "On"] as Array<String>;
    const FIELD_COLOR_MODES = ["Accent only", "Per field"] as Array<String>;

    // Choice values in the order the picker lists them.
    function choices(key as String) as Array<Number> {
        if (kind(key) == KIND_FIELD) {
            return Fields.MENU_ORDER;
        }
        var out = new Array<Number>[count(key)];
        for (var i = 0; i < out.size(); i++) {
            out[i] = i;
        }
        return out;
    }

    function kind(key as String) as Number {
        if (Settings.SLOT_KEYS.indexOf(key) >= 0) { return KIND_FIELD; }
        if (isColor(key)) { return KIND_COLOR; }
        return KIND_LIST;
    }

    function isColor(key as String) as Boolean {
        return key.equals(Settings.KEY_HOUR_COLOR)
            || key.equals(Settings.KEY_MINUTE_COLOR)
            || key.equals(Settings.KEY_ACCENT_COLOR);
    }

    function count(key as String) as Number {
        var k = kind(key);
        if (k == KIND_FIELD) { return Fields.COUNT; }
        if (k == KIND_COLOR) { return Palette.count(); }
        if (key.equals(Settings.KEY_STYLE)) { return Style.count(); }
        if (key.equals(Settings.KEY_THEME)) { return Theme.count(); }
        if (key.equals(Settings.KEY_TIME_SIZE)) { return TimeSize.count(); }
        return ON_OFF.size();
    }

    function name(key as String, value as Number) as String {
        var k = kind(key);
        if (k == KIND_FIELD) { return Fields.name(value); }
        if (k == KIND_COLOR) { return Palette.NAMES[value]; }
        if (key.equals(Settings.KEY_STYLE)) { return Style.NAMES[value]; }
        if (key.equals(Settings.KEY_THEME)) { return Theme.NAMES[value]; }
        if (key.equals(Settings.KEY_TIME_SIZE)) { return TimeSize.NAMES[value]; }
        if (key.equals(Settings.KEY_FIELD_COLORS)) { return FIELD_COLOR_MODES[value]; }
        return ON_OFF[value];
    }
}
