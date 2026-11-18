---
name: ciq-simulator-capture
description: Render a Connect IQ watch face in the Garmin simulator and capture clean, reliable screenshots (round crop, always-on mode, fake data, batch renders of every style). Use when checking a visual change, making README screenshots, or comparing variants.
---

# Rendering and capturing the simulator

Scripts in `scripts/` (copy to a scratch dir and run from there):
- `winid.swift`: lists the simulator's window IDs (compile: `swiftc -O -o winlist winid.swift`)
- `shot.sh`: build, load into the FR970 simulator, capture the simulator window to `$OUT`
- `circle.sh <full.png> <out.png>`: crop the FR970 screen and mask it round (transparent corners)

## Rules learned the hard way
1. **Capture by window ID, never by screen region.** Another app (e.g. a terminal) can stay
   frontmost; region captures then grab the user's screen. `screencapture -x -o -l<id>` captures the
   simulator window even when it is covered. Never commit a capture without looking at it.
2. **The owner name changes after a restart** ("ConnectIQ" vs "Connect IQ Device Simulator"), so
   match the window by PID and size (`awk '$(NF-1)==755'`), not by name.
3. **Wait ~16 s after `monkeydo`.** A blue triangle means the app is still loading.
4. **If every page shows the loading triangle, the simulator has stalled** after many reloads
   (seen after ~4–6 loads in a row): quit it (`osascript -e 'quit app "simulator"'; pkill -x simulator`),
   reopen, wait ~15 s, re-run. For batches, check each capture or restart proactively.
5. Crop offsets scale with window pixel width: for FR970 at width 1510 px the screen centre is
   (768, 912) with radius 452. Use `circle.sh`, which derives these from the width.
6. Do not put the simulator's device skin (Garmin's artwork and logo) in public screenshots:
   crop to the screen only.

## Faking data safely
The simulator has 0 steps, no location ("--" for sunrise), etc. To show realistic values:
1. `cp source/Fields.mc $SCRATCH/Fields.mc.bak` (and Settings.mc)
2. Temporarily hard-code a value (e.g. `case STEPS: return 12345;`) or change a default (style, slot)
3. Render
4. Restore from the backup and confirm with `diff -q`, then rebuild. Always restore in the same command.

## Always-on (AOD)
`osascript -e 'tell application "System Events" to tell process "simulator" to click menu item "Always-On" of menu 1 of menu item "Display Mode" of menu 1 of menu bar item "Settings" of menu bar 1'`
then switch back to "High Power". The simulator flags burn-in violations.

## Contact sheets
ffmpeg (no drawtext here) stacks images: `ffmpeg -i a.png -i b.png -filter_complex "[0][1]hstack=2" out.png`.
Labels must be drawn on the watch itself (see ciq-icon-workflow). `open -a Preview file.png` shows the user.

## Keep README screenshots in sync
- After ANY visual change, re-render **all** style screenshots in one pass with the same defaults,
  not just the style you touched; shared code (arcs, icons, fonts) changes the others too.
- `for f in docs/screenshots/*.png; do git log -1 --format=%h -- $f; done` shows which are stale.
- Browsers and GitHub cache images: a hard refresh (Cmd+Shift+R) shows new ones.

## Launcher icon from a render
Draw the icon in a scratch preview, capture, crop its disc, mask it round and scale it to the device's
launcher size (`launcherIcon` in the device's `compiler.json`; FR970 = 65×65, which also removes the
"launcher icon will be scaled" warning):
`ffmpeg -i full.png -vf "crop=D:D:X:Y,scale=130:130,format=rgba,geq=...a='if(lte(hypot(X-64.5,Y-64.5),64),255,0)',scale=65:65:flags=lanczos" resources/drawables/launcher_icon.png`
