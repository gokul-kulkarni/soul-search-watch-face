import Toybox.Lang;

// Colour arithmetic on 0xRRGGBB numbers.
module Colors {

    // Mixes a toward b: t = 0 gives a, t = 1 gives b.
    function blend(a as Number, b as Number, t as Float) as Number {
        var r = channel(a, 16) + (channel(b, 16) - channel(a, 16)) * t;
        var g = channel(a, 8) + (channel(b, 8) - channel(a, 8)) * t;
        var bl = channel(a, 0) + (channel(b, 0) - channel(a, 0)) * t;
        return (r.toNumber() << 16) | (g.toNumber() << 8) | bl.toNumber();
    }

    function channel(c as Number, shift as Number) as Number {
        return (c >> shift) & 0xFF;
    }
}
