# cc-ribbit 🐸

> 你装了[抽鞭子](https://github.com/oldwinter/claude-code-whip)让 CC 干活。CC 干完了。然后它等了你二十分钟。

**CC learned. Now it calls you back.**

给 Claude Code 加上提示音——CC 等你确认时，青蛙来敲门；任务完成，微波炉叮一声告诉你饭好了。

---

## 安装

```bash
git clone https://github.com/wgjuan2314/cc-ribbit.git
cd cc-ribbit
bash install.sh
```

重启 `claude` 后生效。

---

## 它会做什么

| 场景 | 声音 | 叙事 |
|------|------|------|
| CC 在等你确认权限 | 🐸 小青蛙呱一声 | 青蛙礼貌地敲门 |
| 等了 30 秒还没来 | 🐸🐸🐸 三声 | 青蛙不耐烦了 |
| 等了 1 分钟还没来 | 🐸🐸🐸🐸🐸 合唱团 | CC 派了增援 |
| 任务完成 | 🔔 微波炉叮 | 干完了，青蛙复命 🐸 |
| 工具执行报错 | 🐱 猫：喵？ | 出事了，但还是可爱地告诉你 |

切出窗口也没关系——macOS 系统通知会弹出来，摸鱼也没法装没看见。

---

## 音效文件

项目不内置音效（避免版权问题）。请自行从 [freesound.org](https://freesound.org) 下载 **CC0 授权**的文件放到 `sounds/` 目录：

- `ribbit.wav` — 搜 `frog ribbit single`
- `ding.wav` — 搜 `microwave ding`
- `meow.wav` — 搜 `cat meow single`

**macOS 用户不放文件也能用**，会自动 fallback 到系统内置音效。

---

## 支持平台

| 系统 | 音频 | 通知 |
|------|------|------|
| macOS | ✅ afplay（内置） | ✅ 系统通知 |
| Linux (PulseAudio) | ✅ paplay | ✅ notify-send |
| Linux (PipeWire) | ✅ pw-play | ✅ notify-send |
| Linux (ALSA) | ✅ aplay | ✅ notify-send |
| Windows | ❌ 暂不支持 | — |

---

## 卸载

```bash
bash uninstall.sh
```

自动清除 `~/.claude/settings.json` 里的 hooks 配置，青蛙全部撤退。

---

## 原理

Claude Code 的 [Hooks 系统](https://code.claude.com/docs/en/hooks)支持在特定事件触发时执行 shell 命令。cc-ribbit 注册了三个 hook：

- `PermissionRequest` → 青蛙叫 + 系统通知 + 渐强计时器
- `Stop` → 叮声 + 系统通知
- `PostToolUseFailure` → 猫叫 + 系统通知

---

## 同一宇宙

- [抽鞭子](https://github.com/oldwinter/claude-code-whip) — 你催 CC 干活
- cc-ribbit — CC 反过来催你

---

## License

MIT
