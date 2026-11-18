#!/bin/bash
set -u

Xvfb "$DISPLAY" -screen 0 "$SCREEN" &
sleep 1

x11vnc -display "$DISPLAY" -forever -shared -localhost \
  -rfbport "$VNC_PORT" -passwd "$VNC_PASSWORD" -noxdamage -q &

# 监听端口，外部用 SSH 隧道或 nginx 访问
websockify --web /usr/share/novnc 0.0.0.0:"$NOVNC_PORT" localhost:"$VNC_PORT" &

# scrcpy 掉线自动重连
while true; do
  adb connect "$ADB_ADDR" >/dev/null 2>&1
  scrcpy -s "$ADB_ADDR" \
    --max-size "$MAX_SIZE" --max-fps "$MAX_FPS" --video-bit-rate "$BITRATE" \
    --no-audio --window-borderless --window-x 0 --window-y 0
  echo "scrcpy exited, retry in 3s..."
  sleep 3
done