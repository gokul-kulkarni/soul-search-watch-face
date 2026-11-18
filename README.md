# Gokul Face — personal Connect IQ watch face (Forerunner 970)

Configurable, crash-safe, AMOLED-aware watch face. Sideloaded, not store-published.

## Styles (Customize → Style)
| Style | Time font | Layout | Slots used |
|---|---|---|---|
| Classic | Roboto Condensed Bold, stacked | 4 pods + 4 arcs | all 8 |
| Overlap | Roboto Condensed Bold, poster size, minutes overlap hours | 4 arcs | arcs |
| Serif | Pridi (built-in serif) | Classic with hairline arcs/rings | all 8 |
| HUD | Seven-segment, drawn in code | 1 field above, 3 below | 4 pods |
| Minimal | Roboto Condensed Regular, one line | 1 data line + 2 lower arcs | bottom pod, lower arcs |
| Analog | Hands, 60-tick dial | 4 pods inside the dial | 4 pods |

Every style has its own always-on view; Minimal's keeps its data line.
Arcs fill upward: top arcs toward 12, bottom arcs from 6 toward 9/3.

## Fields (any slot, 28 + None)
Heart rate, steps, battery, Body Battery, stress, calories, floors, weekly active minutes,
notifications, temperature, next sun event, recovery, date, **sleep score**, VO2 max,
weekly intensity minutes, weekly vigorous minutes,
Pulse Ox, wind (arrow follows wind direction), UV index, humidity, rain chance, feels like,
sunrise, sunset, respiration, weekly run distance, altitude, next calendar event.

## Customize (on the watch)
Style · Theme · Time size · Hours / Minutes / Accent colour (17 colours or "Theme", with swatches) ·
Field colours (per field / accent only) · Dynamic colours on/off · each of the 8 slots.
Every item opens a picker list; fields are grouped health / activity / watch / weather.

## Long-press
Touch and hold any field to open the related Garmin app (sleep, Body Battery, weather, ...).

## Themes and colour
Night, Glacier, Moss, Ember, Mono, Paper (light), Neon, Midnight. Each field has its own colour
(heart rate rose, sleep violet, Body Battery blue...), with tracks and frames faintly tinted to match. Battery, Body Battery, stress, heart rate,
recovery, sleep score, Pulse Ox, UV, rain and temperature change colour with their value
(deeper shades on light themes).

## Always-on
Dim, stacked clock on black that shifts each minute (AMOLED burn-in protection).

## Code map
| File | Role |
|---|---|
| `FaceView.mc` | Draws arcs, pods, stacked time; crash fallback |
| `Layout.mc` | Slot positions, shared by drawing and long-press hit-testing |
| `FaceDelegate.mc` | Long-press → open the field's Garmin app |
| `Gauge.mc` / `Pod.mc` | The two slot renderers |
| `Fields.mc` | Field catalogue: ids, names, one read per field, long-press target |
| `FieldStyle.mc` | Text, gauge fill and value-driven colour per field |
| `Sensors.mc` / `Complic.mc` / `Sun.mc` / `WeatherData.mc` | Data sources: sensors, Garmin complications (sleep, VO2 max...), weather |
| `Icons.mc` / `IconsExtra.mc` | Icons drawn from shapes, so they recolour freely |
| `Theme.mc` / `Palette.mc` / `Fonts.mc` / `TimeSize.mc` | Themes, picker colours, fonts, time sizes |
| `Settings.mc` / `Options.mc` / `SettingsMenu.mc` | Stored settings, their choices, the picker menus |
| `LowPower.mc` | Always-on view |

## One-time setup
1. Download the **Connect IQ SDK Manager** from https://developer.garmin.com/connect-iq/sdk/
   and sign in with your Garmin account.
2. In the SDK Manager, install the latest SDK, then under **Devices** download **Forerunner 970**.
3. In VS Code, install the **Monkey C** extension (Garmin). Run
   `Monkey C: Verify Installation` and point it at `keys/developer_key.der`.

## Build and simulate
```
make run          # builds bin/GokulFace.prg and opens it in the simulator
```
(Start the simulator first with `make sim` if `monkeydo` can't connect.)

## Put it on the watch (sideload)
One-time: `brew install libmtp`, and on the watch set **System → USB Mode → MTP**.

```
make install      # build, copy to GARMIN/Apps (replacing the old copy), verify size
```
Then unplug; on the watch: hold UP → Watch Face → **Gokul Face**.

If it says "No watch found":
- **Quit Chrome** — it keeps Garmin devices open over WebUSB, which also flips the watch back
  to Garmin mode (closing tabs is not enough).
- Close OpenMTP / Garmin Express.
- Plug straight into the Mac (no hub), re-seat the clip; the watch should show it is connected.

Customise from the watch-face menu → **Customize**. Keep `keys/` private and backed up: the same
key must sign every rebuild.
