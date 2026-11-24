import Toybox.Graphics;
import Toybox.Lang;

// Time digits with a vertical gradient, solid or as an outline.
module Shine {

    const CAP = 0.72;            // digit cap height as a fraction of font size
    const OUTLINE = 0.012;       // outline stroke, fraction of screen radius

    // size: the font's pixel size, so the gradient spans the digits' height.
    function text(dc as Dc, x as Numeric, y as Numeric, font as Graphics.FontType, s as String,
                  just as Number, size as Numeric, stops as Array<Number>, outline as Boolean) as Void {
        var stroke = outline ? (Layout.r * OUTLINE).toNumber() : 0;
        if (outline && stroke < 1) { stroke = 1; }
        var t = new ShineText(x, y, font, s, just, stroke);
        var cap = size * CAP;
        Grad.bands(dc, y - cap / 2, y + cap / 2, stops, t.method(:paint));
        if (outline) {
            dc.setColor(Theme.color(Theme.BG), Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y, font, s, just);
        }
    }
}

// What one band repaints: the text, or its eight offset copies for an outline.
class ShineText {
    private var _x as Numeric;
    private var _y as Numeric;
    private var _font as Graphics.FontType;
    private var _s as String;
    private var _just as Number;
    private var _stroke as Number;

    function initialize(x as Numeric, y as Numeric, font as Graphics.FontType, s as String,
                        just as Number, stroke as Number) {
        _x = x; _y = y; _font = font; _s = s; _just = just; _stroke = stroke;
    }

    function paint(dc as Dc) as Void {
        var o = _stroke;
        if (o == 0) {
            dc.drawText(_x, _y, _font, _s, _just);
            return;
        }
        var offs = [[-o, 0], [o, 0], [0, -o], [0, o], [-o, -o], [o, o], [-o, o], [o, -o]];
        for (var i = 0; i < offs.size(); i++) {
            dc.drawText(_x + offs[i][0], _y + offs[i][1], _font, _s, _just);
        }
    }
}
