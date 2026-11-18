import Toybox.Lang;
import Toybox.WatchUi;

// Touch-and-hold a field to open the related Garmin app.
class FaceDelegate extends WatchUi.WatchFaceDelegate {

    function initialize() {
        WatchFaceDelegate.initialize();
    }

    function onPress(clickEvent as WatchUi.ClickEvent) as Boolean {
        var xy = clickEvent.getCoordinates();
        var slot = Layout.slotAt(xy[0], xy[1]);
        if (slot == null) {
            return false;
        }
        return Complic.open(Fields.app(Settings.slots[slot]));
    }
}
