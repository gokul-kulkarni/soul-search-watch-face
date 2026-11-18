---
name: ciq-data-sources
description: Where each watch-face metric comes from in Connect IQ (ActivityMonitor, SensorHistory, Complications, Weather), the permissions and units needed, and what is not available. Use when adding or debugging a data field.
---

# Data sources for watch-face fields

| Metric | Source | Notes |
|---|---|---|
| Heart rate | `Activity.getActivityInfo().currentHeartRate`, else `ActivityMonitor.getHeartRateHistory(1,true)` | skip `INVALID_HR_SAMPLE` |
| Steps, calories, floors | `ActivityMonitor.getInfo()` (`steps`, `calories`, `floorsClimbed`) | goals: `stepGoal`, `floorsClimbedGoal` |
| Intensity / vigorous min (week) | `ActivityMonitor.getInfo().activeMinutesWeek.total` / `.vigorous` | goal `activeMinutesWeekGoal`; vigorous counts double |
| Recovery | `ActivityMonitor.Info.timeToRecovery` (hours) | guard with `has` |
| Body Battery, stress | `SensorHistory.getBodyBatteryHistory` / `getStressHistory` (`ORDER_NEWEST_FIRST`) | permission `SensorHistory` |
| Battery | `System.getSystemStats().battery` | |
| Notifications | `System.getDeviceSettings().notificationCount` | |
| Sleep score, VO2 max, Pulse Ox, respiration, altitude, weekly run, calendar | `Complications.getComplication(new Complications.Id(COMPLICATION_TYPE_*)).value` | permission `ComplicationSubscriber`; value may be Number, Float or String |
| Temperature, feels-like, wind, UV, humidity, rain | `Weather.getCurrentConditions()` | Celsius and m/s; convert at display time (`temperatureUnits`, `distanceUnits`) |
| Weather condition | `.condition` (`Weather.CONDITION_*`, 50+) | group into ~7 icons |
| Sunrise / sunset / night | `Weather.getSunrise/getSunset(observationLocationPosition, moment)` | null without location (simulator shows "--") |

## Rules
- Every getter returns `null` when data is missing; display `--`, never crash.
- Store temperatures in Celsius and wind in km/h internally, so colour thresholds stay correct;
  convert only for display (we once coloured 53 °F as "hot").
- Long-press targets come from the same `COMPLICATION_TYPE_*`; `Complications.exitTo` throws if
  there is no app: catch it.

## Not available to watch faces
- Which days you ran this week (weekly-run "dots" can only show days elapsed).
- Phone-app settings for sideloaded apps.
- The units of complication values are not always clear in the simulator: check on the watch.
