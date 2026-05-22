# cc-ribbit 🐸

> You whipped Claude Code into working. CC finished. Then it waited for you for twenty minutes.  
> 你装了[抽鞭子](https://github.com/oldwinter/claude-code-whip)让 CC 干活。CC 干完了。然后它等了你二十分钟。

**CC learned. Now it calls you back.**

Adds sound alerts and system notifications to Claude Code — a frog knocks when CC needs confirmation, a ding when the task is done, and if you're still away after 30 seconds, Siri starts talking.

给 Claude Code 加上提示音和系统通知——CC 等你确认时青蛙来敲门，任务完成叮一声，失焦 30 秒还不回来就让 Siri 开口催你。

---

## Install / 安装

**Prerequisites / 前置条件**

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code/quickstart) installed and working (run `claude` in your terminal to verify)
- macOS or Linux
- git

已安装并能在终端正常运行 `claude` 命令即可。

**Steps / 步骤**

```bash
git clone https://github.com/wgjuan2314/cc-ribbit.git
cd cc-ribbit
bash install.sh
```

Then quit and restart Claude Code: / 安装完成后，退出并重启 Claude Code：

```bash
# exit current session / 退出当前会话
exit

# restart / 重新启动
claude
```

**Verify / 验证安装**

Run any Claude Code task that requires permission — you should hear a frog ribbit. 🐸

触发任意需要权限确认的操作，听到青蛙叫声即表示安装成功。

---

## What it does / 它会做什么

| Scene / 场景 | Sound / 声音 | Story / 叙事 |
|---|---|---|
| CC waiting, you're in terminal / CC 等你确认，你在终端 | 🐸 ribbit after 3s / 3 秒后呱一声 | Polite knock / 青蛙礼貌敲门 |
| CC waiting, you switched away / CC 等你确认，你切去别的 app | 🐸 instant ribbit + notification / 立刻呱 + 弹通知 | Frog follows you / 青蛙追过来了 |
| Still waiting at 30s / 等了 30 秒没来 | 🐸🐸🐸 three ribbits + notification / 三声 + 通知 | Getting impatient / 青蛙不耐烦了 |
| Still waiting at 60s / 等了 1 分钟没来 | 🐸×7 chorus + notification / 合唱团 + 通知 | The whole pond shows up / CC 派了整个池塘 |
| Task done, in terminal, took ≥ 30s / 任务完成，你在终端，耗时 ≥ 30s | 🔔 ding / 叮 | Worth a heads-up / 值得一声告知 |
| Task done, you switched away / 任务完成，你切去别的 app | 🔔 ding + notification / 叮 + 通知 | Mission complete. Frog reporting back. 🐸 / 干完了，青蛙复命 🐸 |
| Still away 30s after task done / 任务完成后 30 秒还没回来 | 🗣️ Siri speaks / Siri 开口 | "Ribbit. Done. Nobody's watching." / "呱，做完了，没人看" |
| Tool error / 工具报错 | 🐱 meow / 猫叫 | Something broke. Cutely. / 出事了，但还是可爱地告诉你 |

**Focus-aware / 焦点感知**: Gentle when you're watching, escalating when you're not. 在终端时轻提醒，切出去后渐强升级。

**Bilingual / 双语通知**: Auto-detects system language, switches between Chinese and English notifications. 自动检测系统语言，中英文通知自动切换。

---

## Sound files / 音效文件

Sound files are not bundled (license reasons). Download **CC0** files from [freesound.org](https://freesound.org) and place them in `sounds/`:

项目不内置音效（避免版权问题）。请从 [freesound.org](https://freesound.org) 下载 **CC0 授权**文件放到 `sounds/` 目录：

- `ribbit.wav` — search `frog ribbit single`
- `ding.wav` — search `microwave ding`
- `meow.wav` — search `cat meow single`

**macOS users**: works out of the box with system fallback sounds.  
**macOS 用户**：不放文件也能用，自动 fallback 到系统音效。

---

## Platform support / 支持平台

| OS / 系统 | Audio / 音频 | Notifications / 通知 |
|---|---|---|
| macOS | ✅ afplay (built-in) | ✅ System notifications |
| Linux (PulseAudio) | ✅ paplay | ✅ notify-send |
| Linux (PipeWire) | ✅ pw-play | ✅ notify-send |
| Linux (ALSA) | ✅ aplay | ✅ notify-send |
| Windows | ❌ not yet | — |

---

## Uninstall / 卸载

```bash
bash uninstall.sh
```

Removes all hooks from `~/.claude/settings.json`. The frogs retreat.  
自动清除 `~/.claude/settings.json` 里的 hooks 配置，青蛙全部撤退。

---

## How it works / 原理

Claude Code's [Hooks system](https://docs.anthropic.com/en/docs/claude-code/hooks) lets you run shell commands on specific events. cc-ribbit registers four hooks:

Claude Code 的 [Hooks 系统](https://docs.anthropic.com/en/docs/claude-code/hooks) 支持在特定事件触发时执行 shell 命令。cc-ribbit 注册了四个 hook：

- `PermissionRequest` → ribbit + notification + escalating timers / 青蛙叫 + 系统通知 + 渐强计时器
- `Stop` → ding + notification + 30s voice reminder / 叮声 + 系统通知 + 30s 语音催促
- `PostToolUseFailure` → meow + notification / 猫叫 + 系统通知
- `PostToolUse` → clears the waiting flag, stops escalation / 清除等待 flag，终止渐强计时器

---

## Same universe / 同一宇宙

- [抽鞭子](https://github.com/oldwinter/claude-code-whip) — You whip CC into working / 你催 CC 干活
- cc-ribbit — CC calls you back / CC 反过来催你

---

## License

MIT
