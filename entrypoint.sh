#!/bin/bash
set -u

Xvfb "$DISPLAY" -screen 0 "$SCREEN" &
sleep 1

x11vnc -display "$DISPLAY" -forever -shared -localhost \
  -rfbport "$VNC_PORT" -passwd "$VNC_PASSWORD" -noxdamage -q &

websockify --web /usr/share/novnc 0.0.0.0:"$NOVNC_PORT" localhost:"$VNC_PORT" &

IDLE_GRACE=${IDLE_GRACE:-30}   # 没人后多少秒断开
idle=0

has_client() {
  # 统计到 x11vnc 的已建立连接数
  [ "$(ss -Htn state established "( sport = :$VNC_PORT )" | wc -l)" -gt 0 ]
}

stop_phone() {
  pkill -x scrcpy 2>/dev/null
  adb disconnect "$ADB_ADDR" >/dev/null 2>&1
}

while true; do
  if has_client; then
    idle=0
    if ! pgrep -x scrcpy >/dev/null; then
      adb connect "$ADB_ADDR" >/dev/null 2>&1
      scrcpy -s "$ADB_ADDR" \
        --max-size "$MAX_SIZE" --max-fps "$MAX_FPS" --video-bit-rate "$BITRATE" \
        --no-audio --window-borderless --window-x 0 --window-y 0 &
    fi
  else
    if pgrep -x scrcpy >/dev/null; then
      idle=$((idle + 2))
      [ "$idle" -ge "$IDLE_GRACE" ] && { stop_phone; idle=0; }
    fi
  fi
  sleep 2
done