# cc-ribbit 🐸

> 你装了[抽鞭子](https://github.com/oldwinter/claude-code-whip)让 CC 干活。CC 干完了。然后它等了你二十分钟。

**CC learned. Now it calls you back.**

给 Claude Code 加上提示音和系统通知——CC 等你确认时青蛙来敲门，任务完成叮一声，失焦 30 秒还不回来就让 Siri 开口催你。

> You whipped Claude Code into working. CC finished. Then it waited for you for twenty minutes.
>
> cc-ribbit adds sound alerts and system notifications to Claude Code — a frog knocks when CC needs confirmation, a ding when the task is done, and if you're still away after 30 seconds, Siri starts talking.

---

## 安装 / Install

```bash
git clone https://github.com/wgjuan2314/cc-ribbit.git
cd cc-ribbit
bash install.sh
```

重启 `claude` 后生效。 / Restart `claude` to activate.

---

## 它会做什么 / What it does

| 场景 | 声音 | 叙事 |
|------|------|------|
| CC 在等你确认（你在终端） | 🐸 3 秒后呱一声 | 青蛙礼貌地敲门 |
| CC 在等你确认（你切去别的 app） | 🐸 立刻呱 + 弹通知 | 青蛙追到你面前 |
| 等了 30 秒还没来 | 🐸🐸🐸 三声 + 弹通知 | 青蛙不耐烦了 |
| 等了 1 分钟还没来 | 🐸×7 合唱团 + 弹通知 | CC 派了整个池塘 |
| 任务完成（你在终端，耗时 ≥ 30s） | 🔔 叮一声 | 干完了，来看结果 |
| 任务完成（你切去别的 app） | 🔔 叮一声 + 弹通知 | 干完了，青蛙复命 🐸 |
| 任务完成后 30 秒你还没回来 | 🗣️ Siri 开口说话 | "呱，做完了，没人看" |
| 工具执行报错 | 🐱 猫：喵？ | 出事了，但还是可爱地告诉你 |

**焦点感知**：在终端时轻提醒，切出去后渐强升级，不打扰也不放过你。  
**双语通知**：自动检测系统语言，中文系统显示中文，其他语言显示英文。

> **Focus-aware**: gentle when you're in the terminal, escalating when you switch away.  
> **Bilingual**: auto-detects system language, shows Chinese or English notifications accordingly.

---

## 音效文件 / Sound files

项目不内置音效（避免版权问题）。请自行从 [freesound.org](https://freesound.org) 下载 **CC0 授权**的文件放到 `sounds/` 目录：

- `ribbit.wav` — 搜 `frog ribbit single`
- `ding.wav` — 搜 `microwave ding`
- `meow.wav` — 搜 `cat meow single`

**macOS 用户不放文件也能用**，会自动 fallback 到系统内置音效。

> Sound files are not bundled (license reasons). Download **CC0** files from [freesound.org](https://freesound.org) and place them in `sounds/`.  
> **macOS users**: works out of the box with system fallback sounds.

---

## 支持平台 / Platform support

| 系统 | 音频 | 通知 |
|------|------|------|
| macOS | ✅ afplay（内置） | ✅ 系统通知 |
| Linux (PulseAudio) | ✅ paplay | ✅ notify-send |
| Linux (PipeWire) | ✅ pw-play | ✅ notify-send |
| Linux (ALSA) | ✅ aplay | ✅ notify-send |
| Windows | ❌ 暂不支持 | — |

---

## 卸载 / Uninstall

```bash
bash uninstall.sh
```

自动清除 `~/.claude/settings.json` 里的 hooks 配置，青蛙全部撤退。

---

## 原理 / How it works

Claude Code 的 [Hooks 系统](https://docs.anthropic.com/en/docs/claude-code/hooks) 支持在特定事件触发时执行 shell 命令。cc-ribbit 注册了四个 hook：

- `PermissionRequest` → 青蛙叫 + 系统通知 + 渐强计时器
- `Stop` → 叮声 + 系统通知 + 30s 语音催促
- `PostToolUseFailure` → 猫叫 + 系统通知
- `PostToolUse` → 清除等待 flag，终止后续渐强计时器

---

## 同一宇宙 / Same universe

- [抽鞭子](https://github.com/oldwinter/claude-code-whip) — 你催 CC 干活 / You whip CC into working
- cc-ribbit — CC 反过来催你 / CC calls you back

---

## License

MIT
