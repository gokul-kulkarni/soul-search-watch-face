---
name: ciq-sideload-mtp
description: Install a built Connect IQ .prg onto a Garmin watch over USB from macOS (no store), and diagnose "watch not found". Use when the user wants the build on their watch, or MTP/OpenMTP/libmtp cannot see the device.
---

# Sideloading to a Garmin watch (macOS)

Store publishing needs a merchant account (not available in every country); sideloading needs
nothing. Phone (Connect IQ app) settings do NOT work for sideloaded apps, so all configuration must
be on the watch (`getSettingsView` + `Application.Storage`).

## Happy path
1. One-time: `brew install libmtp` (ask the user first: it installs software).
2. Watch: **System → USB Mode → MTP**.
3. `make install`: builds, then `tools/mtp-install` finds `GARMIN/Apps` by name, replaces the old
   `.prg`, sends the new one and verifies the size.
4. Unplug: the watch installs on disconnect. Then hold UP → Watch Face → pick it.

## Diagnose with ioreg first (before asking the user to re-plug)
If the user says "not detected", check `ioreg` straight away: more than once the watch was already
connected in MTP mode, and the "not detected" came from looking too early or at the wrong tool.

```
ioreg -p IOUSB -l -w0 | grep -E '"(idVendor|idProduct)"'          # Garmin vendor = 2334
ioreg -l -w0 -r -c IOUSBHostDevice | grep IOUserClientCreator        # who holds the device
log show --last 15m --style compact --predicate 'process == "kernel"' | grep -i usb
```
| What you see | Meaning | Fix |
|---|---|---|
| No USB device at all, no kernel USB events | no data connection | re-seat the charging clip, plug straight into the Mac (no hub), try another cable; watch should show "connected" |
| `idProduct = 3`, class 255 | watch is in **Garmin mode** | switch USB Mode to MTP, replug |
| `idProduct = 20949` (FR970) | **MTP mode**, good | install |
| `IOUserClientCreator = ... Google Chrome` | Chrome holds it via WebUSB (even with no Garmin tabs) and flips it back to Garmin mode | quit Chrome fully (ask the user: it closes their tabs) |
| `ptpcamerad` / Image Capture | macOS camera daemon grabs MTP devices | `pkill -x ptpcamerad` right before installing (harmless, it respawns). It sometimes survives the kill (same PID), yet installs still succeed, so do not block on it |
| No popup after mode switch | macOS accessory security may be blocking a "new" device | user checks System Settings → Privacy & Security → Allow accessories (a security setting: never change it yourself) |
| OpenMTP open | it holds the device | quit OpenMTP |

## libmtp gotchas (why tools/mtp-install.c exists)
- `mtp-sendfile` path parsing fails on Garmin (`could not get storage id from parent id`): send by folder ID instead.
- `LIBMTP_Get_First_Device()` returns a *cached* device: `LIBMTP_Get_Files_And_Folders` is not
  allowed on it. Open with `LIBMTP_Detect_Raw_Devices` + `LIBMTP_Open_Raw_Device_Uncached`.
- With the uncached handle, `LIBMTP_Get_Folder_List` is empty: walk root → `GARMIN` → `Apps`
  with `LIBMTP_Get_Files_And_Folders` per level.
- Always verify by listing the folder and comparing the file size.

## Other notes
- `pgrep -fl chrome` also matches Electron apps (VS Code, Postman, Claude, Orca: their "chrome_crashpad"
  helpers). Check `IOUserClientCreator` instead to see whether Google Chrome really holds the watch.
- After installing, the watch moves the `.prg` out of `GARMIN/Apps`, so the next install reports
  "Installed" rather than "Replaced". That is normal.
