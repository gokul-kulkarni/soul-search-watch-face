import Toybox.Lang;

// Colours offered by the colour picker. Index 0 means "use the theme".
module Palette {

    const THEME = 0;

    const NAMES = [
        "Theme", "White", "Silver", "Grey", "Red", "Coral", "Orange", "Amber",
        "Yellow", "Lime", "Green", "Teal", "Cyan", "Blue", "Purple", "Pink",
        "Brown", "Espresso"
    ] as Array<String>;

    // COLORS[0] is a placeholder; THEME resolves to the theme's own colour.
    const COLORS = [
        0x000000, 0xFFFFFF, 0xC0C0C0, 0x8A8A8A, 0xFF3B30, 0xFF6F61, 0xFF7A1A, 0xFFB13C,
        0xFFD60A, 0xA8E05F, 0x34C759, 0x2EC4B6, 0x4FC3F7, 0x2F7CF6, 0x9B5DE5, 0xFF4FA3,
        0x8C5A3C, 0x3B2F25
    ] as Array<Number>;

    function count() as Number {
        return NAMES.size();
    }

    // The picked colour, or the given theme colour when "Theme" is selected.
    function resolve(index as Number, themeColor as Number) as Number {
        return index == THEME ? themeColor : COLORS[index];
    }
}
