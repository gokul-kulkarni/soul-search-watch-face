---
name: ciq-watchface-design
description: Design rules and rendering pitfalls for Garmin AMOLED watch faces (Connect IQ): always-on/burn-in, arcs and caps, anti-aliasing, fonts, text fitting, icons, colour and themes, layout. Use when designing or changing how a watch face looks.
---

# Watch-face design rules (Connect IQ, AMOLED)

## Work with the user
- **Suggest before implementing** visual changes: describe options (a table with a recommendation),
  render a preview, let them pick, then build. Never redesign what they did not flag.
- Show renders at **real watch size**; zoom only for detail checks.

## Always-on (AMOLED)
- `System.getDeviceSettings().requiresBurnInProtection`: in sleep, draw on black, dim greys
  (~0x8C8C8C / 0x5E5E5E), under ~10% of pixels lit, and shift the content a few pixels every minute.
- Each style needs its own always-on view; keep one data line at most.
- No seconds, no per-second updates: once a minute is the battery-friendly default.

## Arcs and rings
- Use native `drawArc`/`drawCircle`: they are smooth. Accept **flat ends**.
- **Round caps do not work**: thick arcs are stroked at angle-dependent offsets, so `fillCircle` caps
  poke out somewhere whatever offset you choose. Building arcs from polygons fixes the caps but
  looks faceted and lumpy at watch size. Users notice both. (Tried four ways; do not retry.)
- Turn on `dc.setAntiAlias(true)` (API 3.2+) at the start of `onUpdate`: it smooths arcs, icons,
  hands and segments; vector fonts are already smooth.
- Make every gauge fill the same way (we used "rising": top arcs toward 12, bottom arcs from 6 up).

## Fonts (FR970)
- Built-in vector faces: RobotoCondensedBold, RobotoCondensedRegular, RobotoRegular, RobotoItalic,
  PridiRegular (serif). `Graphics.getVectorFont({:face => [...], :size => px})`, with a system-font fallback.
- `dc.drawRadialText` (4.2.1+, vector fonts only) sets text along an arc: read clockwise on top
  arcs and counter-clockwise on bottom arcs so it is never upside down.
- Bundling other fonts costs memory and loses radial text: prefer built-ins or digits drawn in code
  (seven-segment works well).
- Fit text: if `getTextWidthInPixels(text, valueFont) > space`, drop to the caption font.
  Full numbers ("12,345") need this in pods and cells.

## Icons
- One consistent style. A solid filled set reads best at ~25–30 px on AMOLED; outlines break up.
- Draw icons from primitives so they take any colour; use cut-outs in the background colour for detail.
- Icons must be self-explanatory. What failed: a battery for Body Battery (confused with the watch
  battery), chevrons for vigorous, an arrow for wind (looks like a location pin), an hourglass for
  recovery, a speedometer for VO2 max. What worked: person with bolt, sprinter with speed lines,
  gust lines with "12 NE" text, a clock with a countdown arrow, a "VO2" badge, a bed for sleep, a
  tilted running shoe with speed lines.
- Check that icons are distinct from each other (drop vs drop, flame vs drop, sunset vs hourglass).

## Colour and themes
- Per-field signature colours plus value-driven colours (battery low = red, stress, sleep score...)
  make a face lively; tint tracks and frames faintly with the field colour instead of grey.
- Light themes: deepen bright colours (blend about 30% toward black) or they vanish on cream.
- Offer a colour picker (hours / minutes / accent) with swatches and a "Theme" default.

## Edge tabs (pods as half-circles on the bezel)
- A pod drawn as `fillCircle` centred ON the screen edge (distance 1.0 R, radius ~0.3 R) is cut by
  the round screen into a half-circle "tab". Users liked these, tinted with the field colour (~16%).
- Put content inside, toward the centre: top/bottom tabs show icon and value side by side (icon over
  value is too tall and clips at the edge); side tabs can stack icon over value.
- Make the arcs meet the tabs so they form one border. The arc circle (radius a·R) meets a tab circle
  (centre on the edge, radius p·R) at `cos θ = (a² + 1 − p²) / (2a)` from each cardinal point:
  a = 0.925, p = 0.3 gives θ ≈ 17°, so each arc spans 90 − 2θ ≈ 55°.
- Tabs at 12 and 6 clash with arc icons placed past the arc ends: move those icons inside the arc,
  just inward of the value text.

## Layout
- The arc layout can depend on the style. Overlap's poster digits fill the centre, so its arc icons
  must stay at the arc ends (shorter 46° arcs); Classic, with tabs, uses tab-to-tab arcs with icons
  inside. Check every style that shares arc code after changing it.
- Show frame variants side by side before choosing (partial ring, full ring, none, soft disc,
  half-circle tab): users pick differently from what you would guess.
- Compute every position as a fraction of the screen radius, so devices of other sizes just work.
- Keep slot positions in one module shared by drawing and long-press hit-testing.
- Long-press: `WatchFaceDelegate.onPress` → nearest slot → `Complications.exitTo(id)`.
