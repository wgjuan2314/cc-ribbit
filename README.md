# cc-ribbit 🐸

> You went to grab coffee. Claude Code finished in 30 seconds. Then it waited for you for twenty minutes.

**A frog calls you back.**

---

## Install

Requires [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code/quickstart). macOS fully tested, Linux community-tested.

```bash
git clone https://github.com/wgjuan2314/cc-ribbit.git
cd cc-ribbit
bash install.sh
```

Restart Claude Code. Trigger any permission request — you should hear a frog. 🐸

---

## What it does

| When | Sound |
|---|---|
| CC waiting, you're in terminal | 🐸 ribbit after 3s |
| CC waiting, you switched away | 🐸 instant ribbit + notification |
| Still waiting at 30s | 🐸🐸🐸 three ribbits + notification |
| Still waiting at 60s | 🐸×7 chorus + notification |
| Task done, in terminal, took ≥ 30s | 🔔 ding |
| Task done, you switched away | 🔔 ding + notification |
| Still away 30s after done | 🗣️ Siri speaks |
| Tool error | 🐱 meow |

Focus-aware: gentle when you're watching, escalating when you're not. Auto-detects system language for bilingual notifications.

---

## Customize

Replace `.wav` files in `~/.claude/cc-ribbit/sounds/` with your own (`ribbit.wav`, `ding.wav`, `meow.wav`). No restart needed.

```bash
# Mute temporarily
touch ~/.claude/cc-ribbit/.disabled

# Unmute
rm ~/.claude/cc-ribbit/.disabled
```

---

## Uninstall

```bash
bash ~/.claude/cc-ribbit/uninstall.sh
```

The frogs retreat.

---

## Same universe

- [OpenWhip](https://github.com/GitFrog1111/OpenWhip) — You whip CC into working
- cc-ribbit — CC calls you back

---

MIT

---

<details>
<summary>中文说明 🐸</summary>

> 你切去喝杯咖啡。Claude Code 30 秒就干完了。然后它等了你二十分钟。

**青蛙反过来催你。**

---

### 安装

需要 [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code/quickstart)。macOS 完整测试，Linux 社区测试。

```bash
git clone https://github.com/wgjuan2314/cc-ribbit.git
cd cc-ribbit
bash install.sh
```

安装完成后重启 Claude Code，触发任意权限确认，听到青蛙叫即安装成功。🐸

---

### 它会做什么

| 场景 | 声音 |
|---|---|
| CC 等你确认，你在终端 | 🐸 3 秒后呱一声 |
| CC 等你确认，你切去别的 app | 🐸 立刻呱 + 弹通知 |
| 等了 30 秒没来 | 🐸🐸🐸 三声 + 通知 |
| 等了 1 分钟没来 | 🐸×7 合唱团 + 通知 |
| 任务完成，你在终端，耗时 ≥ 30s | 🔔 叮 |
| 任务完成，你切出去了 | 🔔 叮 + 通知 |
| 做完 30 秒还没回来 | 🗣️ Siri 开口 |
| 工具报错 | 🐱 猫叫 |

焦点感知：在终端时轻提醒，切出去后渐强升级。自动检测系统语言，通知中英文自动切换。

---

### 自定义

把 `~/.claude/cc-ribbit/sounds/` 里的 `.wav` 换成自己的（保持同名：`ribbit.wav`、`ding.wav`、`meow.wav`），即时生效，无需重启。

```bash
# 临时静音
touch ~/.claude/cc-ribbit/.disabled

# 恢复
rm ~/.claude/cc-ribbit/.disabled
```

---

### 卸载

```bash
bash ~/.claude/cc-ribbit/uninstall.sh
```

青蛙全部撤退。

</details>
