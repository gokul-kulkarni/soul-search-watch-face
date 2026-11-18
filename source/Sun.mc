import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Weather;

// Weather-derived fields: temperature and next sunrise/sunset.
module Sun {

    const SECONDS_PER_DAY = 86400;
    var _isSunrise as Boolean = true;

    function conditions() as Weather.CurrentConditions? {
        if (Toybox has :Weather) {
            return Weather.getCurrentConditions();
        }
        return null;
    }

    // Current temperature in Celsius.
    function temperature() as Number? {
        var c = conditions();
        if (c == null) {
            return null;
        }
        var t = c.temperature;
        if (t == null) {
            return null;
        }
        return t.toNumber();
    }

    // Converts a Celsius reading to the user's preferred unit for display.
    function toUserUnits(celsius as Number) as Number {
        if (System.getDeviceSettings().temperatureUnits == System.UNIT_STATUTE) {
            return (celsius * 9 / 5) + 32;
        }
        return celsius;
    }

    // True when the most recently formatted event was a sunrise.
    function isNextSunrise() as Boolean {
        return _isSunrise;
    }

    // Today's sunrise or sunset as text; sunrise when isRise, otherwise sunset.
    function eventText(isRise as Boolean) as String {
        var c = conditions();
        if (c == null) {
            return Fields.PLACEHOLDER;
        }
        if (!(Weather has :getSunrise)) {
            return Fields.PLACEHOLDER;
        }
        var loc = c.observationLocationPosition;
        if (loc == null) {
            return Fields.PLACEHOLDER;
        }
        var m = isRise ? Weather.getSunrise(loc, Time.now()) : Weather.getSunset(loc, Time.now());
        if (m == null) {
            return Fields.PLACEHOLDER;
        }
        var info = Gregorian.info(m, Time.FORMAT_SHORT);
        return Clock.formatHourMinute(info.hour, info.min);
    }

    function nextEventText() as String {
        var c = conditions();
        if (c == null) {
            return Fields.PLACEHOLDER;
        }
        if (!(Weather has :getSunrise)) {
            return Fields.PLACEHOLDER;
        }
        var loc = c.observationLocationPosition;
        if (loc == null) {
            return Fields.PLACEHOLDER;
        }
        var now = Time.now();
        var rise = Weather.getSunrise(loc, now);
        var set = Weather.getSunset(loc, now);
        if (rise == null || set == null) {
            return Fields.PLACEHOLDER;
        }
        if (now.lessThan(rise)) {
            return show(rise, true);
        }
        if (now.lessThan(set)) {
            return show(set, false);
        }
        var tomorrow = Weather.getSunrise(loc, now.add(new Time.Duration(SECONDS_PER_DAY)));
        return tomorrow == null ? Fields.PLACEHOLDER : show(tomorrow, true);
    }

    function show(moment as Time.Moment, isSunrise as Boolean) as String {
        _isSunrise = isSunrise;
        var info = Gregorian.info(moment, Time.FORMAT_SHORT);
        return Clock.formatHourMinute(info.hour, info.min);
    }
}
