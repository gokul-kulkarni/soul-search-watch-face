import Toybox.ActivityMonitor;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.System;
import Toybox.SensorHistory;

// Raw on-device sensor reads. Every getter returns null when data is
// unavailable; callers must handle that.
module Sensors {

    function stepGoal() as Number? {
        var goal = ActivityMonitor.getInfo().stepGoal;
        return (goal instanceof Number && goal > 0) ? goal : null;
    }

    function goal(field as Symbol) as Number? {
        var info = ActivityMonitor.getInfo();
        var v = null;
        if (field == :floorsClimbedGoal && info has :floorsClimbedGoal) {
            v = info.floorsClimbedGoal;
        } else if (field == :activeMinutesWeekGoal && info has :activeMinutesWeekGoal) {
            v = info.activeMinutesWeekGoal;
        }
        return v instanceof Number ? v : null;
    }

    function heartRate() as Number? {
        var info = Activity.getActivityInfo();
        if (info != null) {
            var hr = info.currentHeartRate;
            if (hr != null) {
                return hr;
            }
        }
        if (ActivityMonitor has :getHeartRateHistory) {
            var sample = ActivityMonitor.getHeartRateHistory(1, true).next();
            if (sample != null && sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
                return sample.heartRate;
            }
        }
        return null;
    }

    function activityNumber(field as Symbol) as Number? {
        var info = ActivityMonitor.getInfo();
        var v = null;
        if (field == :steps) {
            v = info.steps;
        } else if (field == :calories) {
            v = info.calories;
        } else if (field == :floorsClimbed && info has :floorsClimbed) {
            v = info.floorsClimbed;
        }
        return v instanceof Number ? v : null;
    }

    function battery() as Number {
        return System.getSystemStats().battery.toNumber();
    }

    // Weekly intensity minutes: :total or :vigorous.
    function activeMinutesWeek(kind as Symbol) as Number? {
        var info = ActivityMonitor.getInfo();
        if (!(info has :activeMinutesWeek)) {
            return null;
        }
        var am = info.activeMinutesWeek;
        if (am == null) {
            return null;
        }
        return kind == :vigorous ? am.vigorous : am.total;
    }

    function recoveryHours() as Number? {
        var info = ActivityMonitor.getInfo();
        if (info has :timeToRecovery) {
            var r = info.timeToRecovery;
            return r instanceof Number ? r : null;
        }
        return null;
    }

    function bodyBattery() as Number? {
        if ((Toybox has :SensorHistory) && (SensorHistory has :getBodyBatteryHistory)) {
            return latestSample(SensorHistory.getBodyBatteryHistory({
                :period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST
            }));
        }
        return null;
    }

    function stress() as Number? {
        if ((Toybox has :SensorHistory) && (SensorHistory has :getStressHistory)) {
            return latestSample(SensorHistory.getStressHistory({
                :period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST
            }));
        }
        return null;
    }

    function latestSample(iter as SensorHistory.SensorHistoryIterator?) as Number? {
        if (iter == null) {
            return null;
        }
        var sample = iter.next();
        if (sample == null) {
            return null;
        }
        var data = sample.data;
        return data == null ? null : data.toNumber();
    }
}
