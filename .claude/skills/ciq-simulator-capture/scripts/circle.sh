#!/bin/zsh
# usage: circle.sh <full window png> <out png>  — crops the FR970 screen and masks it round.
IN=$1; OUT=$2
W=$(sips -g pixelWidth "$IN" | awk '/pixelWidth/{print $2}')
CX=$(( W * 768 / 1510 )); CY=$(( W * 912 / 1510 )); R=$(( W * 452 / 1510 ))
ffmpeg -loglevel error -y -i "$IN" -vf "crop=$((2*R)):$((2*R)):$((CX-R)):$((CY-R)),scale=480:480,format=rgba,geq=r='r(X,Y)':g='g(X,Y)':b='b(X,Y)':a='if(lte(hypot(X-239.5,Y-239.5),239),255,0)'" "$OUT"
