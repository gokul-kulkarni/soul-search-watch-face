#!/bin/zsh
# Build the face, load it in the FR970 simulator, capture the simulator window to $OUT.
# Usage: OUT=/path/full.png WINLIST=/path/winlist ./shot.sh   (run from the project root)
set -e
make build >/dev/null 2>&1 || { make build 2>&1 | tail -5; exit 1; }
SDK="$(cat "$HOME/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg")"
pgrep -x simulator >/dev/null || { open "$SDK/bin/ConnectIQ.app"; sleep 14; }
(timeout 40 "$SDK/bin/monkeydo" bin/GokulFace.prg fr970 >/dev/null 2>&1 &)
sleep 16
WID=$("$WINLIST" "$(pgrep -x simulator)" | awk '$(NF-1)==755{print $1; exit}')
[ -n "$WID" ] || { echo "simulator window not found"; exit 1; }
screencapture -x -o -l"$WID" "$OUT"
