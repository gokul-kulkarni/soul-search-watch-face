import Toybox.Lang;

// Colour palettes. Each row: background, foreground, track, hours, minutes, accent.
module Theme {

    const BG = 0;
    const FG = 1;
    const TRACK = 2;
    const HOUR = 3;
    const MINUTE = 4;
    const ACCENT = 5;

    const NAMES = ["Night", "Glacier", "Moss", "Ember", "Mono", "Paper", "Neon", "Midnight"] as Array<String>;

    const PALETTES = [
        [0x000000, 0xFFFFFF, 0x2E2E2E, 0xFFFFFF, 0xFF7A1A, 0xFF7A1A],
        [0x000000, 0xE8F4FF, 0x1F2C36, 0xFFFFFF, 0x4FC3F7, 0x4FC3F7],
        [0x000000, 0xEDEFE6, 0x283024, 0xD8E8C8, 0x8BC34A, 0x8BC34A],
        [0x000000, 0xFFE9E0, 0x35211C, 0xFF5A3C, 0xFFB13C, 0xFF7A3C],
        [0x000000, 0xFFFFFF, 0x2E2E2E, 0xFFFFFF, 0x9A9A9A, 0xFFFFFF],
        [0xF2EDE4, 0x3B2F25, 0xD9CFC0, 0x3B2F25, 0x8C5A3C, 0x8C5A3C],
        [0x000000, 0xFFFFFF, 0x262626, 0xFFFFFF, 0xFF2D95, 0x00E5FF],
        [0x0A1430, 0xEAF2FF, 0x1E2A4A, 0xFFFFFF, 0x5AC8FA, 0x5AC8FA]
    ] as Array<Array<Number>>;

    // How strongly field colours show in tracks and pod frames (0 = invisible).
    const TRACK_TINT = 0.24;
    const LIGHT_DARKEN = 0.3;

    const LIGHT_THEME_MIN_BG = 0x808080;

    function isLightBackground() as Boolean {
        return PALETTES[Settings.theme][BG] > LIGHT_THEME_MIN_BG;
    }

    // Deepens a bright colour on light backgrounds so it keeps contrast.
    function adapt(c as Number) as Number {
        return isLightBackground() ? Colors.blend(c, 0x000000, LIGHT_DARKEN) : c;
    }

    // A faint version of a colour against the background, for tracks and frames.
    function tint(c as Number, strength as Float) as Number {
        return Colors.blend(color(BG), c, strength);
    }

    function count() as Number {
        return PALETTES.size();
    }

    // Theme colour for a role, with the user's colour picks applied on top.
    function color(role as Number) as Number {
        var base = PALETTES[Settings.theme][role];
        if (role == HOUR) { return Palette.resolve(Settings.hourColor, base); }
        if (role == MINUTE) { return Palette.resolve(Settings.minuteColor, base); }
        if (role == ACCENT) { return Palette.resolve(Settings.accentColor, base); }
        return base;
    }

}
