---
name: ciq-icon-workflow
description: The preview-and-approve loop for designing watch-face icons or visual variants: scratch copy of the project, labelled grids rendered at real size in the simulator, options A/B/C, user picks, then build into the real face. Use when designing or changing icons or comparing visual options.
---

# Icon / variant preview workflow

The user wanted to see options before anything changed. This loop worked well.

1. **Never touch the real face while exploring.** Copy the project to the scratchpad:
   `cp -R manifest.xml monkey.jungle resources source <scratch>/preview/ && cp keys/developer_key.der <scratch>/preview/keys/`
2. In the copy, add a `Preview` module and swap `Style.draw(dc)` for `Preview.draw(dc)` in `FaceView.mc`.
3. Draw a **3×3 labelled grid** per page (9 items): icon at real size (~0.17 R) with a label in a
   small vector font (`RobotoCondensedRegular`, ~0.085 R). `FONT_XTINY` is too wide on the FR970:
   labels overlap.
4. For options, show **real size in the top row and about 2× below**, labelled "A …", "B …".
5. Render each page with `ciq-simulator-capture` (window-ID capture, wait 16 s), crop round,
   stack with ffmpeg, and `open -a Preview` so the user sees it.
6. Present a table: option, how it reads, **my pick and why**. Let the user choose letters.
7. Iterate on the chosen one (tilt, curve, size) with the same preview loop.
8. Only after approval, port the code into the project, strict-compile, and render the real
   styles once to confirm.

## Review checklist before showing a sheet
- Each icon distinct from its neighbours; nothing reads as something else.
- Readable at real size (look at the top row, not the zoom).
- Labels not overlapping; no capture of another window; no loading triangle.
