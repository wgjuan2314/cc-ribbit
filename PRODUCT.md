# cc-ribbit 产品交互文档

> 你装了抽鞭子让 CC 干活。CC 干完了。然后它等了你二十分钟。

**版本**：v1.1  
**状态**：已发布

---

## 一、产品定位

Claude Code 在等用户确认或任务完成时，用户常因切换到其他 app 而错过，导致 CC 干等，浪费时间。

cc-ribbit 通过声音 + 系统通知提醒用户回来，核心设计原则：

- **在焦点内：轻提醒，不打扰**——用户就在那，看得见，不需要强催
- **失焦后：及时提醒，渐强升级**——用户不在，要把他拉回来
- **报错：无论如何都提醒**——错误需要关注，不分焦点状态

---

## 二、音效设计

| 音效 | 文件 | 场景 | 叙事 |
|------|------|------|------|
| 🐸 单声呱 | `ribbit.wav` | 需要确认（首次） | 青蛙礼貌敲门 |
| 🐸🐸🐸 三声呱 | `ribbit.wav` × 3 | 需要确认（30s 未响应） | 青蛙不耐烦了 |
| 🐸×5 合唱团 | `ribbit.wav` × 多音调 | 需要确认（60s 未响应） | CC 派了增援 |
| 🔔 叮 | `ding.wav` | 任务完成 | 饭好了，来吃 |
| 🐱 喵 | `meow.wav` | 工具报错 | 出事了，但还是可爱地告诉你 |

---

## 三、完整交互逻辑

### 3.1 焦点状态定义

- **焦点内**：终端 app（Terminal / iTerm2 / Warp 等）是当前最前台窗口
- **失焦**：用户切换到其他 app，终端不在前台

---

### 3.2 需要确认（PermissionRequest）

计时从权限出现那一刻开始，所有定时器同时启动，每次触发时**现查焦点状态**。

| 时间点 | 焦点内行为 | 失焦行为 |
|--------|-----------|---------|
| t = 0s | 启动计时器，静默等待 | 🐸 立刻呱一声 + 弹通知 |
| t = 3s | 🐸 呱一声（礼貌延迟） | — |
| t = 30s | 🔇 不响 | 🐸🐸🐸 三声 + 弹通知 |
| t = 60s | 🔇 不响 | 🐸×5 合唱团 + 弹通知 |

**边缘场景**：用户在焦点内，t=3s 呱了一声，t=7s 切去其他 app  
→ t=30s 定时器触发，检测到失焦 → 三声呱，自然兜住，无需额外处理

用户确认后（PostToolUse 触发时）：清除计时器 flag，停止后续叫声。

---

### 3.3 任务完成（Stop）

读取 hook stdin 中的 `duration_ms` 字段获取任务耗时。

| 条件 | 焦点内行为 | 失焦行为 |
|------|-----------|---------|
| 耗时 < 30s | 🔇 不响，不通知 | 🔔 叮一声 + 弹通知 |
| 耗时 ≥ 30s | 🔔 叮一声 | 🔔 叮一声 + 弹通知 |
| 失焦叮后 30s 仍未回来 | — | 🗣️ 语音播报（中文：`呱，做完了，没人看` / 英文：`Ribbit. Done. Nobody's watching.`） |

**语音语言**：自动检测 macOS 系统语言，中文系统用 Meijia 语音，其他用 Samantha 语音。

**设计理由**：
- 焦点内的短任务用户能看到，响了反而烦
- 失焦时无论长短都需要提醒用户回来决定下一步
- 焦点内的长任务（≥ 30s）值得一声告知

---

### 3.4 工具报错（PostToolUseFailure）

| 焦点内行为 | 失焦行为 |
|-----------|---------|
| 🐱 喵一声 | 🐱 喵一声 + 弹通知 |

报错不区分焦点状态，始终提醒，因为错误需要用户关注。

---

## 四、通知文案

→ 见第七节（双语最终版）

---

## 五、跨平台焦点检测实现

### macOS
```bash
FRONTMOST=$(osascript -e \
  'tell application "System Events" to get name of first application process whose frontmost is true')
[[ "$FRONTMOST" == *"Terminal"* || "$FRONTMOST" == *"iTerm"* ||
   "$FRONTMOST" == *"Warp"* || "$FRONTMOST" == *"Alacritty"* ]]
```
**依赖**：内置，零依赖  
**可靠性**：✅ 极稳定

### Linux（X11）
```bash
WIN_NAME=$(xdotool getactivewindow getwindowname 2>/dev/null)
[[ "$WIN_NAME" == *"terminal"* || "$WIN_NAME" == *"Terminal"* ||
   "$WIN_NAME" == *"Konsole"* || "$WIN_NAME" == *"Alacritty"* ]]
```
**依赖**：`xdotool`（`sudo apt install xdotool`），安装时自动提示  
**可靠性**：✅ 稳定

### Linux（Wayland）
Wayland 无统一焦点检测 API，不同桌面环境（GNOME / Sway / Hyprland）方案各异。  
**v1 降级方案**：跳过焦点检测，所有事件均按"失焦"逻辑处理，等同于全提醒模式。

### Windows / WSL
**v2 支持**，当前不处理。

---

## 六、Hook 事件与 stdin 数据

| Hook | 关键 stdin 字段 | 用途 |
|------|---------------|------|
| `PermissionRequest` | `tool_name` | 记录是哪个工具在等待 |
| `Stop` | `duration_ms` | 判断任务耗时是否 ≥ 30s |
| `PostToolUseFailure` | `error` | 错误类型（仅记录，不影响声音逻辑） |
| `PostToolUse` | — | 清除等待 flag，终止渐强计时器 |

---

## 七、通知文案（最终确认版）

自动检测 macOS 系统语言，中文系统显示中文，其他语言显示英文。

| 触发时机 | 中文 | 英文 |
|---------|------|------|
| 确认（t=0 失焦） | `CC 在等你确认 🐸` | `CC is waiting for you 🐸` |
| 确认（t=30s 失焦） | `CC 还在等你... 🐸🐸🐸` | `Hello? Still there? 🐸🐸🐸` |
| 确认（t=60s 失焦） | `CC 派了增援！整个池塘都来了 🐸🐸🐸🐸🐸` | `CC called for backup. The whole pond is here. 🐸🐸🐸🐸🐸` |
| 任务完成（失焦） | `干完了，青蛙复命 🐸` | `Mission complete. Frog reporting back. 🐸` |
| 报错（失焦） | `出事了，但还是可爱地告诉你 🐱` | `Something broke. Cutely. 🐱` |
| 语音（任务完成 30s 未回） | `呱，做完了，没人看` | `Ribbit. Done. Nobody's watching.` |

---

## 八、功能实现状态

### v1.0（已完成）
- [x] 音效文件：ribbit.wav、meow.wav（ding.wav fallback 系统音效）
- [x] 基础 hooks 脚本（ribbit.sh）
- [x] 渐强逻辑（30s 三声、60s 合唱）
- [x] 系统通知
- [x] 一键安装 / 卸载脚本
- [x] macOS + Linux 双平台支持

### v1.1（已完成）
- [x] 焦点状态检测（macOS osascript + Linux xdotool）
- [x] 任务耗时读取（从 hook stdin 读 `duration_ms`）
- [x] 3 秒礼貌延迟（焦点内 PermissionRequest 等 3s 再呱）
- [x] 焦点内短任务静默（Stop 耗时 < 30s 不响）
- [x] 焦点内不弹系统通知（通知只在失焦时推送）
- [x] 定时器焦点状态实时判断（t=30s/60s 触发时现查焦点）
- [x] 任务完成失焦 30s 语音催促（中英双语 Siri）
- [x] 所有通知文案中英双语自动切换

### v2.0（规划中）
- [ ] Windows 原生支持
- [ ] Wayland 适配
- [ ] 声音主题切换（青蛙 / 猫 / 鸭子）

---

## 九、版本规划

| 版本 | 内容 | 状态 |
|------|------|------|
| v1.0 | 基础音效 + hooks + 安装脚本 | ✅ 已发布 |
| v1.1 | 焦点感知 + 耗时阈值 + 礼貌延迟 + 双语通知 + 语音催促 | ✅ 已发布 |
| v2.0 | Windows、Wayland、主题切换 | 📋 规划中 |
