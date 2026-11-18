import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;

// Time and date formatting that respects the watch's 12/24h setting.
module Clock {

    function formatHourMinute(hour as Number, minute as Number) as String {
        return displayHour(hour) + ":" + minute.format("%02d");
    }

    // Hours and minutes, both two digits, for the stacked layout.
    function stackedParts() as Array<String> {
        var t = System.getClockTime();
        var h = displayHour(t.hour);
        return [h.length() < 2 ? "0" + h : h, t.min.format("%02d")];
    }

    function displayHour(hour as Number) as String {
        if (System.getDeviceSettings().is24Hour) {
            return hour.format("%02d");
        }
        var h = hour % 12;
        return (h == 0 ? 12 : h).format("%d");
    }

    function weekday() as String {
        var info = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        return (info.day_of_week as String).toUpper();
    }

    function dayOfMonth() as String {
        return Gregorian.info(Time.now(), Time.FORMAT_SHORT).day.format("%d");
    }
}
