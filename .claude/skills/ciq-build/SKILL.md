---
name: ciq-build
description: Build and type-check a Garmin Connect IQ (Monkey C) watch face with the SDK on macOS, and fix the compile errors that come up. Use when compiling, adding a device, adding permissions, or hitting monkeyc errors.
---

# Building a Connect IQ watch face

## Where things are (macOS)
- Current SDK path: `cat "$HOME/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg"`
- Device files: `~/Library/Application Support/Garmin/ConnectIQ/Devices/<id>/` (`compiler.json` has resolution, display type; `simulator.json` lists vector font faces)
- API reference you can grep: `$SDK/bin/api.debug.xml` (functions, `@since`, constants such as `COMPLICATION_TYPE_*`, `CONDITION_*`)

## Commands
```
make build                         # monkeyc -d fr970 -f monkey.jungle -o bin/X.prg -y keys/developer_key.der -w
make build DEVICE=vivoactive6      # any device listed in manifest.xml
monkeyc ... -l 3                   # STRICT type check: run before every commit
```
- A device must be listed in `manifest.xml` products AND downloaded in SDK Manager.
  While a target device downloads, build against a downloaded one with the same display type
  (e.g. vivoactive6 for AMOLED) by temporarily adding it to the manifest; remove it afterwards.

## Strict-mode (-l 3) errors we hit, and the fix
| Error | Cause | Fix |
|---|---|---|
| `Cannot find symbol ':x' on type 'Null'` after `if (c == null \|\| ...)` | narrowing is lost across `\|\|` | split into two separate `if (c == null) { return; }` checks |
| `PolyType<Double or Float> does not match Float` | `Math.sin/cos` return Double | `(expr).toFloat()`, or type params as `Numeric` |
| `Cannot find symbol ':toNumber' on type 'Null'` | `String.substring` returns `String?` | assign, null-check, then convert |
| `Permission 'ComplicationSubscriber' required` | using `Toybox.Complications` | add `<iq:uses-permission id="ComplicationSubscriber"/>` |
| `mismatched input 'private'` | missing `;` on the previous const | check the line above |
| `Undefined symbol ':i'` | variable used outside its loop | move the computation inside the loop |
| `Object of type 'Float' does not match return type 'Number'` | a decimal constant (e.g. `SPAN = 55.3`) flows into a `Number` function | keep layout angles whole degrees, or `.toNumber()` |

## Conventions that kept the code healthy
- Small modules, one job each (`Style*.mc`, `Glyphs*.mc`, `Fields.mc`/`FieldStyle.mc`).
- One sensor read per field per frame (`Fields.numeric`), then derive text, progress and colour from it.
- Wrap the whole `onUpdate` in try/catch and fall back to a bare clock: never show the "IQ!" crash screen.
- Guard newer APIs with `has` (`dc has :setAntiAlias`, `Toybox has :Complications`, `Graphics has :getVectorFont`).
- Settings live in `Application.Storage` (phone settings do not work for sideloaded apps).

## Publishing the source safely
- Never commit keys: `.gitignore` must cover `keys/`, `developer_key*`, `*.der`, `*.pem`.
  The VS Code Monkey C extension can drop an extra `source/developer_key` (an unencrypted private key).
- Also ignore `bin/`, `.impeccable/config.local.json`, `.claude/settings.local.json`.
- Before pushing: `git diff --cached --name-only | grep -iE "developer_key|\.der$|\.pem$|local\.json|^bin/|^keys/"` must be empty.
