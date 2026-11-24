import Toybox.Graphics;
import Toybox.Lang;

// Switchable watch-face designs. Each style draws itself, its always-on view,
// and reports where its slots are for long-press hit-testing.
module Style {

    const CLASSIC = 0;
    const SERIF = 1;
    const HUD = 2;
    const MINIMAL = 3;
    const ANALOG = 4;

    const NAMES = ["Classic", "Serif", "HUD", "Minimal", "Analog"] as Array<String>;

    const CLASSIC_SCALE = 1.25;   // overlapping digits, sized to clear the tabs and arc icons
    const ARC_PEN = 0.034;
    const ARC_PEN_CLASSIC = 0.05;   // heavier, to balance the edge tabs

    function count() as Number {
        return NAMES.size();
    }

    function isSerif() as Boolean {
        return Settings.style == SERIF;
    }

    function timeFace() as Array<String> {
        if (Settings.style == SERIF) { return Fonts.FACE_SERIF; }
        if (Settings.style == MINIMAL) { return Fonts.FACE_REGULAR; }
        return Fonts.FACE_BOLD;
    }

    // Time font size relative to the chosen Large/Medium/Small size.
    function timeScale() as Float {
        if (Settings.style == CLASSIC) { return CLASSIC_SCALE; }
        if (Settings.style == SERIF) { return 1.3; }
        if (Settings.style == MINIMAL) { return 1.2; }
        return 1.0;
    }

    // Pixel size of the time font, for gradients that span the digits.
    function timePx() as Float {
        return Layout.r * TimeSize.font() * timeScale();
    }

    function aodScale() as Float {
        return Settings.style == MINIMAL ? 0.8 : 1.0;
    }

    function arcPenRatio() as Float {
        return Settings.style == CLASSIC ? ARC_PEN_CLASSIC : ARC_PEN;
    }


    function draw(dc as Dc) as Void {
        switch (Settings.style) {
            case SERIF:   StyleSerif.draw(dc); break;
            case HUD:     StyleHud.draw(dc); break;
            case MINIMAL: StyleMinimal.draw(dc); break;
            case ANALOG:  StyleAnalog.draw(dc); break;
            default:      StyleClassic.draw(dc); break;
        }
    }

    function drawLowPower(dc as Dc) as Void {
        switch (Settings.style) {
            case HUD:     StyleHud.drawLowPower(dc); break;
            case MINIMAL: StyleMinimal.drawLowPower(dc); break;
            case ANALOG:  StyleAnalog.drawLowPower(dc); break;
            default:      LowPower.drawStacked(dc); break;
        }
    }

    // [[slot, x, y], ...] for every slot this style shows.
    function slotCenters() as Array<Array<Numeric>> {
        switch (Settings.style) {
            case HUD:     return StyleHud.centers();
            case MINIMAL: return StyleMinimal.centers();
            case SERIF:   return StyleSerif.centers();
            case ANALOG:  return StyleAnalog.centers();
        }
        var out = StyleClassic.podCenters(Pod.contentDistance());
        out.addAll(StyleClassic.arcCenters([0, 1, 2, 3]));
        return out;
    }
}
