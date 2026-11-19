import Toybox.Graphics;
import Toybox.Lang;

// Switchable watch-face designs. Each style draws itself, its always-on view,
// and reports where its slots are for long-press hit-testing.
module Style {

    const CLASSIC = 0;
    const OVERLAP = 1;
    const SERIF = 2;
    const HUD = 3;
    const MINIMAL = 4;
    const ANALOG = 5;

    const NAMES = ["Classic", "Overlap", "Serif", "HUD", "Minimal", "Analog"] as Array<String>;

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
        if (Settings.style == OVERLAP) { return 1.55; }
        if (Settings.style == SERIF) { return 1.3; }
        if (Settings.style == MINIMAL) { return 1.2; }
        return 1.0;
    }

    function aodScale() as Float {
        return Settings.style == MINIMAL ? 0.8 : 1.0;
    }

    // Overlap's poster digits fill the centre, so its arc icons sit at the arc ends.
    function arcIconsInside() as Boolean {
        return Settings.style != OVERLAP;
    }

    function arcPenRatio() as Float {
        return Settings.style == CLASSIC ? ARC_PEN_CLASSIC : ARC_PEN;
    }


    function draw(dc as Dc) as Void {
        switch (Settings.style) {
            case OVERLAP: StyleOverlap.draw(dc); break;
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
            case OVERLAP: return StyleClassic.arcCenters([0, 1, 2, 3]);
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
