import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class FaceView extends WatchUi.WatchFace {

    private var _sleeping as Boolean = false;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        Layout.init(dc.getWidth(), dc.getHeight());
        Fonts.init(Layout.r);
    }

    function onUpdate(dc as Dc) as Void {
        try {
            // Smooth edges on arcs, icons, hands and segments.
            if (dc has :setAntiAlias) {
                dc.setAntiAlias(true);
            }
            Fonts.refresh(Layout.r);
            if (_sleeping && System.getDeviceSettings().requiresBurnInProtection) {
                Style.drawLowPower(dc);
            } else {
                drawActive(dc);
            }
        } catch (e) {
            // Never show the "IQ!" crash screen: fall back to a bare clock.
            System.println("draw failed: " + e.getErrorMessage());
            LowPower.drawStacked(dc);
        }
    }

    function onEnterSleep() as Void {
        _sleeping = true;
        WatchUi.requestUpdate();
    }

    function onExitSleep() as Void {
        _sleeping = false;
        WatchUi.requestUpdate();
    }

    private function drawActive(dc as Dc) as Void {
        var bg = Theme.color(Theme.BG);
        dc.setColor(bg, bg);
        dc.clear();
        Style.draw(dc);
    }
}
