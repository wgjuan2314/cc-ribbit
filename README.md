# cc-ribbit 🐸

> 你装了[抽鞭子](https://github.com/oldwinter/claude-code-whip)让 CC 干活。CC 干完了。然后它等了你二十分钟。  
> You whipped Claude Code into working. CC finished. Then it waited for you for twenty minutes.

**CC learned. Now it calls you back.**

给 Claude Code 加上提示音和系统通知——CC 等你确认时青蛙来敲门，任务完成叮一声，失焦 30 秒还不回来就让 Siri 开口催你。

Adds sound alerts and system notifications to Claude Code — a frog knocks when CC needs confirmation, a ding when the task is done, and if you're still away after 30 seconds, Siri starts talking.

---

## 安装 / Install

```bash
git clone https://github.com/wgjuan2314/cc-ribbit.git
cd cc-ribbit
bash install.sh
```

重启 `claude` 后生效。Restart `claude` to activate.

---

## 它会做什么 / What it does

| 场景 / Scene | 声音 / Sound | 叙事 / Story |
|---|---|---|
| CC 等你确认，你在终端 / CC waiting, you're in terminal | 🐸 3 秒后呱一声 / ribbit after 3s | 青蛙礼貌敲门 / Polite knock |
| CC 等你确认，你切去别的 app / CC waiting, you switched away | 🐸 立刻呱 + 弹通知 / instant ribbit + notification | 青蛙追过来了 / Frog follows you |
| 等了 30 秒没来 / Still waiting at 30s | 🐸🐸🐸 三声 + 通知 / three ribbits + notification | 青蛙不耐烦了 / Getting impatient |
| 等了 1 分钟没来 / Still waiting at 60s | 🐸×7 合唱团 + 通知 / chorus + notification | CC 派了整个池塘 / The whole pond shows up |
| 任务完成，你在终端，耗时 ≥ 30s / Task done, in terminal, took ≥ 30s | 🔔 叮 / ding | 值得一声告知 / Worth a heads-up |
| 任务完成，你切去别的 app / Task done, you switched away | 🔔 叮 + 通知 / ding + notification | 干完了，青蛙复命 🐸 / Mission complete |
| 任务完成后 30 秒还没回来 / Still away 30s after task done | 🗣️ Siri 开口 / Siri speaks | "呱，做完了，没人看" / "Ribbit. Done. Nobody's watching." |
| 工具报错 / Tool error | 🐱 猫叫 / meow | 出事了，但还是可爱地告诉你 / Something broke. Cutely. |

**焦点感知 / Focus-aware**：在终端时轻提醒，切出去后渐强升级。Gentle when you're watching, escalating when you're not.

**双语通知 / Bilingual**：自动检测系统语言，中文或英文通知自动切换。Auto-detects system language, switches between Chinese and English notifications.

---

## 音效文件 / Sound files

项目不内置音效（避免版权问题）。请从 [freesound.org](https://freesound.org) 下载 **CC0 授权**文件放到 `sounds/` 目录：

Sound files are not bundled (license reasons). Download **CC0** files from [freesound.org](https://freesound.org) and place them in `sounds/`:

- `ribbit.wav` — 搜 / search `frog ribbit single`
- `ding.wav` — 搜 / search `microwave ding`
- `meow.wav` — 搜 / search `cat meow single`

**macOS 用户不放文件也能用**，自动 fallback 到系统音效。  
**macOS users**: works out of the box with system fallback sounds.

---

## 支持平台 / Platform support

| 系统 / OS | 音频 / Audio | 通知 / Notifications |
|---|---|---|
| macOS | ✅ afplay (built-in) | ✅ System notifications |
| Linux (PulseAudio) | ✅ paplay | ✅ notify-send |
| Linux (PipeWire) | ✅ pw-play | ✅ notify-send |
| Linux (ALSA) | ✅ aplay | ✅ notify-send |
| Windows | ❌ not yet | — |

---

## 卸载 / Uninstall

```bash
bash uninstall.sh
```

自动清除 `~/.claude/settings.json` 里的 hooks 配置，青蛙全部撤退。  
Removes all hooks from `~/.claude/settings.json`. The frogs retreat.

---

## 原理 / How it works

Claude Code 的 [Hooks 系统](https://docs.anthropic.com/en/docs/claude-code/hooks) 支持在特定事件触发时执行 shell 命令。cc-ribbit 注册了四个 hook：

Claude Code's [Hooks system](https://docs.anthropic.com/en/docs/claude-code/hooks) lets you run shell commands on specific events. cc-ribbit registers four hooks:

- `PermissionRequest` → 青蛙叫 + 系统通知 + 渐强计时器 / ribbit + notification + escalating timers
- `Stop` → 叮声 + 系统通知 + 30s 语音催促 / ding + notification + 30s voice reminder
- `PostToolUseFailure` → 猫叫 + 系统通知 / meow + notification
- `PostToolUse` → 清除等待 flag，终止渐强计时器 / clears the waiting flag, stops escalation

---

## 同一宇宙 / Same universe

- [抽鞭子](https://github.com/oldwinter/claude-code-whip) — 你催 CC 干活 / You whip CC into working
- cc-ribbit — CC 反过来催你 / CC calls you back

---

## License

MIT
