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

    // Rotates the hue by deg (positive = toward yellow from red), keeping
    // saturation and brightness. Greys come back unchanged.
    function hueShift(c as Number, deg as Float) as Number {
        var r = channel(c, 16) / 255.0;
        var g = channel(c, 8) / 255.0;
        var b = channel(c, 0) / 255.0;
        var mx = r > g ? (r > b ? r : b) : (g > b ? g : b);
        var mn = r < g ? (r < b ? r : b) : (g < b ? g : b);
        var d = mx - mn;
        if (d < 0.02) {
            return c;
        }
        var h;
        if (mx == r) {
            h = 60.0 * (g - b) / d;
        } else if (mx == g) {
            h = 60.0 * (b - r) / d + 120.0;
        } else {
            h = 60.0 * (r - g) / d + 240.0;
        }
        h = h + deg;
        while (h < 0.0) { h += 360.0; }
        while (h >= 360.0) { h -= 360.0; }
        return fromHsv(h, d / mx, mx);
    }

    function fromHsv(h as Float, s as Float, v as Float) as Number {
        var cc = v * s;
        var hp = h / 60.0;
        var x = cc * (1.0 - (hp - 2.0 * (hp / 2.0).toNumber() - 1.0).abs());
        var rgb;
        switch (hp.toNumber()) {
            case 0: rgb = [cc, x, 0.0]; break;
            case 1: rgb = [x, cc, 0.0]; break;
            case 2: rgb = [0.0, cc, x]; break;
            case 3: rgb = [0.0, x, cc]; break;
            case 4: rgb = [x, 0.0, cc]; break;
            default: rgb = [cc, 0.0, x]; break;
        }
        var m = v - cc;
        return (byte(rgb[0] + m) << 16) | (byte(rgb[1] + m) << 8) | byte(rgb[2] + m);
    }

    function byte(f as Float) as Number {
        var n = (f * 255.0 + 0.5).toNumber();
        return n < 0 ? 0 : (n > 255 ? 255 : n);
    }
}
