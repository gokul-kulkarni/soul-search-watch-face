import Toybox.Graphics;
import Toybox.Lang;

// Fonts sized to the screen. Uses the device's scalable faces where available,
// falling back to fixed system fonts on older devices. Time, value and
// always-on fonts depend on the style and time size, and reload when those change.
module Fonts {

    const FACE_BOLD = ["RobotoCondensedBold", "RobotoRegular"] as Array<String>;
    const FACE_REGULAR = ["RobotoCondensedRegular", "RobotoRegular"] as Array<String>;
    const FACE_SERIF = ["PridiRegular", "RobotoRegular"] as Array<String>;

    // Sizes as fractions of the screen radius.
    const VALUE_SIZE = 0.17;
    const CAPTION_SIZE = 0.12;
    const RADIAL_SIZE = 0.15;
    const AOD_SIZE = 0.36;

    var time as Graphics.FontType = Graphics.FONT_NUMBER_THAI_HOT;
    var value as Graphics.FontType = Graphics.FONT_SMALL;
    var caption as Graphics.FontType = Graphics.FONT_XTINY;
    var aod as Graphics.FontType = Graphics.FONT_NUMBER_MEDIUM;
    var radial as Graphics.VectorFont? = null;
    var _loadedKey as Number = -1;

    function init(radius as Number) as Void {
        if (!(Graphics has :getVectorFont)) {
            return;
        }
        caption = orFallback(vector(FACE_BOLD, radius * CAPTION_SIZE), caption);
        radial = vector(FACE_BOLD, radius * RADIAL_SIZE);
        refresh(radius);
    }

    // Reloads style-dependent fonts only when the style or time size changed.
    function refresh(radius as Number) as Void {
        var key = Settings.style * 10 + Settings.timeSize;
        if (key == _loadedKey || !(Graphics has :getVectorFont)) {
            return;
        }
        var face = Style.timeFace();
        time = orFallback(vector(face, radius * TimeSize.font() * Style.timeScale()), Graphics.FONT_NUMBER_THAI_HOT);
        value = orFallback(vector(Style.isSerif() ? FACE_SERIF : FACE_BOLD, radius * VALUE_SIZE), Graphics.FONT_SMALL);
        aod = orFallback(vector(face, radius * AOD_SIZE * Style.aodScale()), Graphics.FONT_NUMBER_MEDIUM);
        _loadedKey = key;
    }

    function vector(face as Array<String>, size as Float) as Graphics.VectorFont? {
        return Graphics.getVectorFont({:face => face, :size => size.toNumber()});
    }

    function orFallback(font as Graphics.VectorFont?, fallback as Graphics.FontType) as Graphics.FontType {
        return font == null ? fallback : font;
    }
}
