import Toybox.Complications;
import Toybox.Lang;

// Garmin system complications: data with no direct sensor API (sleep score,
// VO2 max, ...) and the target for long-press "open the related app".
module Complic {

    // Latest value as a whole number, or null.
    function number(type as Complications.Type) as Number? {
        var v = raw(type);
        if (v instanceof Number) { return v; }
        if (v instanceof Float || v instanceof Double || v instanceof Long) { return v.toNumber(); }
        return null;
    }

    // Latest value as display text, or null.
    function text(type as Complications.Type) as String? {
        var v = raw(type);
        if (v == null) { return null; }
        if (v instanceof Float || v instanceof Double) { return v.format("%.1f"); }
        return v.toString();
    }

    function raw(type as Complications.Type) as Object? {
        if (!(Toybox has :Complications)) {
            return null;
        }
        try {
            return Complications.getComplication(new Complications.Id(type)).value;
        } catch (e) {
            return null;
        }
    }

    // Opens the Garmin app behind a complication. Returns false if there is none.
    function open(type as Complications.Type?) as Boolean {
        if (type == null) {
            return false;
        }
        if (!(Toybox has :Complications)) {
            return false;
        }
        try {
            Complications.exitTo(new Complications.Id(type));
            return true;
        } catch (e) {
            return false;
        }
    }
}
