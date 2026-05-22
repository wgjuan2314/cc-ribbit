#!/bin/bash

# 用户临时关闭开关：存在 .disabled 文件则直接退出
[ -f "$HOME/.claude/cc-ribbit/.disabled" ] && exit 0

CONFIG="$HOME/.claude/cc-ribbit/config"
SOUNDS="$HOME/.claude/cc-ribbit/sounds"
FLAG="/tmp/cc-ribbit-waiting"
STOP_FLAG="/tmp/cc-ribbit-stop"

# shellcheck source=/dev/null
source "$CONFIG" 2>/dev/null

# 在脚本入口读取 stdin（hook 数据只能读一次）
HOOK_INPUT=$(cat 2>/dev/null)

# config 未显式设置时才自动检测；config 设置可覆盖（方便测试）
[[ -z "${IS_CHINESE+x}" ]] && { defaults read -g AppleLanguages 2>/dev/null | grep -q '"zh' && IS_CHINESE=1 || IS_CHINESE=0; }
export IS_CHINESE

# ── 焦点检测 ────────────────────────────────────────────

is_focused() {
  if [[ "$OS_TYPE" == "macos" ]]; then
    local frontmost
    frontmost=$(osascript -e \
      'tell application "System Events" to get name of first application process whose frontmost is true' \
      2>/dev/null)
    [[ "$frontmost" == *"Terminal"* || "$frontmost" == *"iTerm"* ||
       "$frontmost" == *"Warp"*     || "$frontmost" == *"Alacritty"* ||
       "$frontmost" == *"Hyper"*    || "$frontmost" == *"kitty"* ]]
  elif [[ "$OS_TYPE" == "linux" ]]; then
    if command -v xdotool &>/dev/null; then
      local win_name
      win_name=$(xdotool getactivewindow getwindowname 2>/dev/null)
      [[ "$win_name" == *"terminal"* || "$win_name" == *"Terminal"* ||
         "$win_name" == *"Konsole"*  || "$win_name" == *"Alacritty"* ||
         "$win_name" == *"Hyper"*    || "$win_name" == *"kitty"* ]]
    else
      # Wayland 或无 xdotool：降级为全提醒模式
      return 1
    fi
  else
    return 1
  fi
}

# ── 音效播放 ─────────────────────────────────────────────

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

play_three_ribbits() {
  play_ribbit 0.9;  sleep 0.3
  play_ribbit 1.1;  sleep 0.3
  play_ribbit 1.25
}

play_chorus() {
  local f="$SOUNDS/ribbit.wav"
  [ ! -f "$f" ] && f="/System/Library/Sounds/Pop.aiff"
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

# ── 双语通知（仅在失焦时调用） ────────────────────────────

send_notify() {
  local msg
  [[ "$IS_CHINESE" == 1 ]] && msg="$1" || msg="$2"

  if [[ "$OS_TYPE" == "macos" ]]; then
    osascript -e "display notification \"$msg\" with title \"cc-ribbit 🐸\"" 2>/dev/null
  elif [[ "$NOTIFY_CMD" == "notify-send" ]]; then
    notify-send "cc-ribbit 🐸" "$msg" 2>/dev/null
  fi
}

# ── 语音催促（macOS 专属，系统语言自动切换） ──────────────

say_reminder() {
  [[ "$OS_TYPE" == "macos" ]] || return 0
  if [[ "$IS_CHINESE" == 1 ]]; then
    say -v Meijia "呱，做完了，没人看" 2>/dev/null
  else
    say -v Samantha "Ribbit. Done. Nobody's watching." 2>/dev/null
  fi
}

# ── 从 hook stdin 读取任务耗时 ────────────────────────────

get_duration_ms() {
  echo "$HOOK_INPUT" | python3 -c \
    "import json,sys; d=json.load(sys.stdin); print(int(d.get('duration_ms',0)))" \
    2>/dev/null || echo "0"
}

# ── 主逻辑 ───────────────────────────────────────────────

case "$1" in
  permission)
    FLAG_TS=$(date +%s)
    echo "$FLAG_TS" > "$FLAG"

    if is_focused; then
      (
        sleep 3
        [[ "$(cat "$FLAG" 2>/dev/null)" == "$FLAG_TS" ]] || exit 0
        play_ribbit 1.0
      ) &
      disown
    else
      play_ribbit 1.0 &
      send_notify "CC 在等你确认 🐸" "CC is waiting for you 🐸"
    fi

    (
      sleep 30
      [[ "$(cat "$FLAG" 2>/dev/null)" == "$FLAG_TS" ]] || exit 0
      if ! is_focused; then
        play_three_ribbits
        send_notify "CC 还在等你... 🐸🐸🐸" "Hello? Still there? 🐸🐸🐸"
      fi
    ) &
    disown

    (
      sleep 60
      [[ "$(cat "$FLAG" 2>/dev/null)" == "$FLAG_TS" ]] || exit 0
      if ! is_focused; then
        send_notify "CC 派了增援！整个池塘都来了 🐸🐸🐸🐸🐸" "CC called for backup. The whole pond is here. 🐸🐸🐸🐸🐸"
        play_chorus
      fi
    ) &
    disown
    ;;

  stop)
    rm -f "$FLAG" 2>/dev/null
    DURATION_MS=$(get_duration_ms)

    if ! is_focused; then
      play_ding
      send_notify "干完了，青蛙复命 🐸" "Mission complete. Frog reporting back. 🐸"

      STOP_TS=$(date +%s)
      echo "$STOP_TS" > "$STOP_FLAG"
      (
        sleep 30
        [[ "$(cat "$STOP_FLAG" 2>/dev/null)" == "$STOP_TS" ]] || exit 0
        is_focused || say_reminder
        rm -f "$STOP_FLAG"
      ) &
      disown
    elif [ "$DURATION_MS" -ge 30000 ]; then
      play_ding
    fi
    ;;

  error)
    rm -f "$FLAG" 2>/dev/null
    play_meow
    # 报错无论焦点状态都响；失焦时额外弹通知
    if ! is_focused; then
      send_notify "出事了，但还是可爱地告诉你 🐱" "Something broke. Cutely. 🐱"
    fi
    ;;

  cleanup)
    rm -f "$FLAG" "$STOP_FLAG" 2>/dev/null
    ;;
esac
