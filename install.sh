#!/bin/bash
set -e

INSTALL_DIR="$HOME/.claude/cc-ribbit"
SETTINGS="$HOME/.claude/settings.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "  @..@"
echo " (----)"
echo "( >__< )   cc-ribbit 安装中..."
echo "^^ ~~ ^^"
echo ""

# ── 检测平台 ──────────────────────────────────────────────

detect_platform() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macos"
    PLAY_CMD="afplay"
    NOTIFY_CMD="macos"
    echo "✓ 检测到 macOS，使用 afplay"
  elif command -v paplay &>/dev/null; then
    OS_TYPE="linux"
    PLAY_CMD="paplay"
    NOTIFY_CMD="$(command -v notify-send &>/dev/null && echo notify-send || echo '')"
    echo "✓ 检测到 Linux (PulseAudio)，使用 paplay"
  elif command -v pw-play &>/dev/null; then
    OS_TYPE="linux"
    PLAY_CMD="pw-play"
    NOTIFY_CMD="$(command -v notify-send &>/dev/null && echo notify-send || echo '')"
    echo "✓ 检测到 Linux (PipeWire)，使用 pw-play"
  elif command -v aplay &>/dev/null; then
    OS_TYPE="linux"
    PLAY_CMD="aplay"
    NOTIFY_CMD="$(command -v notify-send &>/dev/null && echo notify-send || echo '')"
    echo "✓ 检测到 Linux (ALSA)，使用 aplay"
  else
    OS_TYPE="unknown"
    PLAY_CMD=""
    NOTIFY_CMD=""
    echo "⚠️  未检测到音频播放器，仅启用系统通知"
  fi
}

detect_platform

# ── 创建目录 ─────────────────────────────────────────────

mkdir -p "$INSTALL_DIR/sounds"
mkdir -p "$INSTALL_DIR/hooks"
echo "✓ 创建目录 $INSTALL_DIR"

# ── 复制文件 ─────────────────────────────────────────────

cp "$SCRIPT_DIR/hooks/ribbit.sh" "$INSTALL_DIR/hooks/ribbit.sh"
chmod +x "$INSTALL_DIR/hooks/ribbit.sh"
cp "$SCRIPT_DIR/uninstall.sh" "$INSTALL_DIR/uninstall.sh"
chmod +x "$INSTALL_DIR/uninstall.sh"
echo "✓ 安装 hooks 脚本"

# 复制音效文件（如果存在）
for sound in ribbit.wav ding.wav meow.wav; do
  if [ -f "$SCRIPT_DIR/sounds/$sound" ]; then
    cp "$SCRIPT_DIR/sounds/$sound" "$INSTALL_DIR/sounds/$sound"
    echo "✓ 复制音效 $sound"
  else
    echo "  ℹ  $sound 未找到，将使用系统默认音效"
  fi
done

# ── 写入平台配置 ──────────────────────────────────────────

cat > "$INSTALL_DIR/config" <<EOF
OS_TYPE=$OS_TYPE
PLAY_CMD=$PLAY_CMD
NOTIFY_CMD=$NOTIFY_CMD
EOF
echo "✓ 写入平台配置"

# ── 合并 settings.json ────────────────────────────────────

python3 - "$SETTINGS" "$INSTALL_DIR" <<'PYTHON'
import json, os, sys

settings_path = sys.argv[1]
install_dir   = sys.argv[2]

if os.path.exists(settings_path):
    with open(settings_path, 'r') as f:
        settings = json.load(f)
else:
    settings = {}

hooks = settings.setdefault("hooks", {})

hooks["PermissionRequest"] = [{"hooks": [{"type": "command", "command": f"bash {install_dir}/hooks/ribbit.sh permission"}]}]
hooks["Stop"]               = [{"hooks": [{"type": "command", "command": f"bash {install_dir}/hooks/ribbit.sh stop"}]}]
hooks["PostToolUseFailure"] = [{"hooks": [{"type": "command", "command": f"bash {install_dir}/hooks/ribbit.sh error"}]}]

# PostToolUse：清理 flag（去重后追加）
post = hooks.setdefault("PostToolUse", [])
cleanup_cmd = f"bash {install_dir}/hooks/ribbit.sh cleanup"
if not any("cc-ribbit" in str(h) for h in post):
    post.append({"hooks": [{"type": "command", "command": cleanup_cmd}]})

os.makedirs(os.path.dirname(settings_path), exist_ok=True)
with open(settings_path, 'w') as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)

print("✓ 写入 Claude Code hooks 配置")
PYTHON

# ── 完成 ─────────────────────────────────────────────────

echo ""
echo "  @..@"
echo " (----)"
echo "( >__< )   安装完成！重启 claude 后生效。"
echo "^^ ~~ ^^"
echo ""
echo "🐸 CC 现在会催你了。 / CC will now call you back."
echo ""
echo "   卸载 / Uninstall: bash ~/.claude/cc-ribbit/uninstall.sh"
echo ""

# 播放一声青蛙验证安装成功
if [[ "$OS_TYPE" == "macos" ]]; then
  f="$INSTALL_DIR/sounds/ribbit.wav"
  [ -f "$f" ] && afplay "$f" 2>/dev/null || afplay "/System/Library/Sounds/Pop.aiff" 2>/dev/null
fi
