#!/bin/bash

INSTALL_DIR="$HOME/.claude/cc-ribbit"
SETTINGS="$HOME/.claude/settings.json"

echo ""
echo "🐸 cc-ribbit 卸载中..."
echo ""

# 从 settings.json 移除 hooks
if [ -f "$SETTINGS" ]; then
  python3 - "$SETTINGS" <<'PYTHON'
import json, sys

settings_path = sys.argv[1]

with open(settings_path, 'r') as f:
    settings = json.load(f)

hooks = settings.get("hooks", {})
for key in ["PermissionRequest", "Stop", "PostToolUseFailure"]:
    hooks.pop(key, None)

if "PostToolUse" in hooks:
    hooks["PostToolUse"] = [h for h in hooks["PostToolUse"] if "cc-ribbit" not in str(h)]
    if not hooks["PostToolUse"]:
        del hooks["PostToolUse"]

settings["hooks"] = hooks

with open(settings_path, 'w') as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)

print("✓ 移除 Claude Code hooks 配置")
PYTHON
else
  echo "  settings.json 不存在，跳过"
fi

# 删除安装目录
rm -rf "$INSTALL_DIR"
rm -f /tmp/cc-ribbit-waiting
echo "✓ 删除安装文件"

echo ""
echo "  @..@"
echo " (----)"
echo "( >__< )   再见！"
echo "^^ ~~ ^^"
echo ""
echo "青蛙走了。重启 claude 后完全生效。"
echo ""
