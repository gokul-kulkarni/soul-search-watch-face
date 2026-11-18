import Toybox.Lang;
import Toybox.System;
import Toybox.Weather;

// Current-conditions readings beyond temperature. Wind is stored in km/h,
// temperatures in Celsius; conversion to user units happens at display time.
module WeatherData {

    const MS_TO_KMH = 3.6;
    const KMH_TO_MPH = 0.621371;

    function windKmh() as Number? {
        var c = Sun.conditions();
        if (c == null) { return null; }
        var s = c.windSpeed;
        return s == null ? null : (s * MS_TO_KMH).toNumber();
    }

    // Direction the wind blows FROM, degrees clockwise from north, or null.
    function windBearing() as Number? {
        var c = Sun.conditions();
        if (c == null) { return null; }
        var b = c.windBearing;
        return b == null ? null : b.toNumber();
    }

    function windForUser(kmh as Number) as Number {
        if (System.getDeviceSettings().distanceUnits == System.UNIT_STATUTE) {
            return (kmh * KMH_TO_MPH).toNumber();
        }
        return kmh;
    }

    function uvIndex() as Number? {
        var c = Sun.conditions();
        if (c == null) { return null; }
        if (!(c has :uvIndex)) { return null; }
        var v = c.uvIndex;
        return v == null ? null : v.toNumber();
    }

    function humidity() as Number? {
        var c = Sun.conditions();
        if (c == null) { return null; }
        var v = c.relativeHumidity;
        return v == null ? null : v.toNumber();
    }

    function precipitation() as Number? {
        var c = Sun.conditions();
        if (c == null) { return null; }
        var v = c.precipitationChance;
        return v == null ? null : v.toNumber();
    }

    function feelsLike() as Number? {
        var c = Sun.conditions();
        if (c == null) { return null; }
        var v = c.feelsLikeTemperature;
        return v == null ? null : v.toNumber();
    }
}
