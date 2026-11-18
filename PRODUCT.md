# Product

<!-- impeccable:product-schema 1 -->

## Platform

garmin-connect-iq

(Not web/iOS/Android: a Garmin Connect IQ watch face written in Monkey C. Primary target is the Forerunner 970: 454×454 round AMOLED. Verified so far in the simulator on the vívoactive 6, 390×390 AMOLED.)

## Users

One primary user, the developer: they wear a Forerunner 970 all day. They glance at the face:
- **all day** for time, date, notifications and battery;
- **in the morning** for sleep and recovery (Body Battery, stress);
- **outdoors** for weather, temperature and sunrise/sunset.

Training-day metrics are secondary. The face may later be shared with friends or through a beta store link. It must stay adaptable to other round AMOLED Garmin devices, but no other users or devices are requirements yet.

## Product Purpose

A personal watch face that fixes what published faces get wrong for this user: limited data configurability, crashes and unreliable fields, and battery cost. Success means the user keeps it as their daily face, can read every field in one glance, and the always-on view doesn't noticeably cut battery life.

## Positioning

Modelled on the Rondo layout pattern (Nimble Wings, Connect IQ store): stacked hours over minutes in the centre, four data pods on the cardinal points, four diagonal arc gauges along the bezel, curated themes, and colours that change with the value. It is our own implementation (own icons, palettes and code), not a copy of Rondo's artwork. What differs from store faces: it never crashes to the "IQ!" error screen, missing data shows `--`, and everything is configured on the watch.

## Operating Context

- Distributed by sideloading: copy the built `.prg` file to `GARMIN/APPS/` over USB with OpenMTP. There is no store listing.
- Phone-app settings don't work for sideloaded apps, so all configuration happens in the on-watch "Customize" menu.
- Built with Connect IQ SDK 9.3.0 via the `Makefile`. The signing key in `keys/` must stay the same across builds.

## Capabilities and Constraints

- 8 configurable slots (4 pods + 4 arc gauges) choosing from 27 data fields (including sleep score via Garmin complications), plus theme, time size (L/M/S), hours/minutes/accent colour picker and dynamic-colour toggle.
- Long-press any field opens the related Garmin app (Complications API, `ComplicationSubscriber` permission).
- **Battery stance:** best usability without wasting battery. That means a useful but minimal always-on view and no per-second updates. Colourful themes are allowed, but dark themes are the efficient default.
- **AMOLED burn-in rule:** in always-on mode, under ~10% of pixels may be lit, and lit pixels must shift each minute.
- Memory limit is about 124 KB for a watch face. Use the device's built-in vector fonts (RobotoCondensed, Roboto) and draw icons from shapes in code, not bitmaps.
- Undecided: font choices, always-on data, seasonal/decorative options.

## Brand Commitments

App name for now: "Gokul Face" (placeholder). No logo or brand assets.

## Product Principles

1. Glanceable first: every field has to read in under a second at arm's length.
2. Never crash: missing data degrades to `--`, never to an error screen.
3. Configure on the wrist: every option is reachable on the watch.
4. Spend battery only where it buys clarity.
5. Our own craft: borrow the layout pattern, never the artwork.
