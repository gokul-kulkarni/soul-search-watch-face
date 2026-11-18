import Toybox.Lang;

// Time display sizes: font size and the vertical offset of each stacked line,
// both as fractions of the screen radius.
module TimeSize {

    const NAMES = ["Large", "Medium", "Small"] as Array<String>;
    const FONT = [0.54, 0.46, 0.38] as Array<Float>;
    const OFFSET = [0.225, 0.19, 0.16] as Array<Float>;

    function count() as Number {
        return NAMES.size();
    }

    function font() as Float {
        return FONT[Settings.timeSize];
    }

    function offset() as Float {
        return OFFSET[Settings.timeSize];
    }
}
