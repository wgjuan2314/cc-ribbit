#!/bin/bash

CONFIG="$HOME/.claude/cc-ribbit/config"
SOUNDS="$HOME/.claude/cc-ribbit/sounds"
FLAG="/tmp/cc-ribbit-waiting"

# shellcheck source=/dev/null
source "$CONFIG" 2>/dev/null

play_ribbit() {
  local rate="${1:-1.0}"
  local file="$SOUNDS/ribbit.wav"
  if [ -f "$file" ]; then
    afplay -r "$rate" "$file" 2>/dev/null
  else
    afplay "/System/Library/Sounds/Pop.aiff" 2>/dev/null
  fi
}

play_ding() {
  local file="$SOUNDS/ding.wav"
  if [ -f "$file" ]; then
    afplay "$file" 2>/dev/null
  else
    afplay "/System/Library/Sounds/Glass.aiff" 2>/dev/null
  fi
}

play_meow() {
  local file="$SOUNDS/meow.wav"
  if [ -f "$file" ]; then
    afplay "$file" 2>/dev/null
  else
    afplay "/System/Library/Sounds/Purr.aiff" 2>/dev/null
  fi
}

# 三声：依次呱呱呱，稍微加大音调差距
play_three_ribbits() {
  local f="$SOUNDS/ribbit.wav"
  afplay -r 0.9  "$f" 2>/dev/null; sleep 0.3
  afplay -r 1.1  "$f" 2>/dev/null; sleep 0.3
  afplay -r 1.25 "$f" 2>/dev/null
}

# 合唱团：两轮密集多音调，中间短停顿
play_chorus() {
  local f="$SOUNDS/ribbit.wav"
  for round in 1 2; do
    afplay -r 0.65 "$f" 2>/dev/null &
    afplay -r 1.40 "$f" 2>/dev/null &
    afplay -r 1.0  "$f" 2>/dev/null &
    sleep 0.04; afplay -r 0.78 "$f" 2>/dev/null &
    sleep 0.03; afplay -r 1.28 "$f" 2>/dev/null &
    sleep 0.07; afplay -r 0.85 "$f" 2>/dev/null &
    sleep 0.02; afplay -r 1.15 "$f" 2>/dev/null &
    wait
    sleep 0.25
  done
}

# 通知同步执行，确保不被父进程退出时杀掉
send_notify() {
  local msg="$1"
  if [[ "$OS_TYPE" == "macos" ]]; then
    osascript -e "display notification \"$msg\" with title \"cc-ribbit 🐸\"" 2>/dev/null
  elif [[ "$NOTIFY_CMD" == "notify-send" ]]; then
    notify-send "cc-ribbit 🐸" "$msg" 2>/dev/null
  fi
}

case "$1" in
  permission)
    # 声音先响，通知跟上，脚本快速退出让 CC 弹权限框
    afplay -r 1.0 "$SOUNDS/ribbit.wav" 2>/dev/null &
    send_notify "CC 在等你确认 🐸"
    echo "$(date +%s)" > "$FLAG"

    # 30秒后：三声
    (
      sleep 30
      [ -f "$FLAG" ] || exit 0
      play_three_ribbits
      send_notify "CC 还在等你... 🐸🐸🐸"
    ) &
    disown

    # 60秒后：合唱团
    (
      sleep 60
      [ -f "$FLAG" ] || exit 0
      send_notify "CC 派了增援！整个池塘都来了 🐸🐸🐸🐸🐸"
      play_chorus
    ) &
    disown
    ;;

  stop)
    rm -f "$FLAG" 2>/dev/null
    play_ding
    send_notify "任务完成！饭好了，来吃 🔔"
    ;;

  error)
    rm -f "$FLAG" 2>/dev/null
    play_meow
    send_notify "出事了，但还是可爱地告诉你 🐱"
    ;;

  cleanup)
    rm -f "$FLAG" 2>/dev/null
    ;;
esac
