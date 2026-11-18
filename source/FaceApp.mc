import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class FaceApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
        Settings.reload();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [new FaceView(), new FaceDelegate()];
    }

    // On-device "Customize" menu. Sideloaded apps can't use phone settings,
    // so all configuration lives here.
    function getSettingsView() as [Views] or [Views, InputDelegates] or Null {
        return [new SettingsMenu(), new SettingsMenuDelegate()];
    }

    function onSettingsChanged() as Void {
        Settings.reload();
        WatchUi.requestUpdate();
    }
}
