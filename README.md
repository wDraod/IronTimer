# IronTimer

**A hardcore rest timer for powerlifters — built for Apple Watch**

IronTimer is a standalone watchOS app designed exclusively for the Big Four barbell movements: Squat, Deadlift, Bench Press, and Overhead Press. Unlike generic timers that only track heart rate, IronTimer enforces ATP-PCr recovery science with a hard lock mechanism, preventing you from cutting rest short before your CNS is ready.

---

## The Science Behind IronTimer

### Why Rest Timers Matter for Strength Training

Most lifters either rest too short (chasing the pump) or rest inconsistently (scrolling their phone). Both sabotage maximal strength output. IronTimer is built around two pillars of exercise physiology:

#### 1. ATP-PCr Resynthesis — The Hard Limit
The phosphocreatine (PCr) system is your primary energy source for maximal-effort compound lifts. After a heavy set, PCr stores are nearly depleted. Research shows:
- **50%** of PCr is restored within ~30 seconds
- **75%** within ~90 seconds
- **95%+** requires 3–5 minutes of full rest

This is why the first 90 seconds are **hard-locked** — no override, no exceptions. Cutting into this window guarantees strength loss on your next set, regardless of how recovered you feel.

#### 2. Heart Rate Recovery (HRR) — The Safety Net
Heart rate is a proxy for cardiovascular and autonomic nervous system (ANS) stress. A resting HR above 120 bpm after the timer ends signals that systemic fatigue has not cleared — even if PCr has partially recovered. IronTimer uses HealthKit real-time HR data to enforce a minimum cardiac recovery threshold before allowing your next set.

#### Why 120 bpm?
120 bpm is a well-established threshold in exercise science literature as the boundary between moderate cardiovascular stress and recovery. Below this point, sympathetic nervous system activation has sufficiently subsided for most trained athletes.

---

## Why IronTimer Beats Every Other Rest Timer

| Feature | Generic Timer | Heart Rate Apps | **IronTimer** |
|---|---|---|---|
| Science-based rest duration | ❌ | ❌ | ✅ |
| ATP hard lock (no skip abuse) | ❌ | ❌ | ✅ |
| Real-time HRR gating | ❌ | Partial | ✅ |
| Powerlifting-specific presets | ❌ | ❌ | ✅ |
| Works independently on Watch | ❌ | ❌ | ✅ |

**The core insight:** Heart rate dropping ≠ nervous system recovered. A timer hitting zero ≠ ATP restored. IronTimer enforces **both** conditions simultaneously — something no other tool does.

---

## Core Features

### ⚡ ATP Hard Lock
The first 90 seconds of every rest period are physically locked. The "Skip" button is disabled regardless of how you feel — because PCr resynthesis requires it.

### 💓 HRR Safety Net (Heart Rate Recovery)
When the timer reaches zero, IronTimer queries your real-time heart rate via HealthKit. If your HR is still above 120 bpm, it automatically extends rest by 30 seconds and alerts you. You can also attempt to skip early — if HR > 120, a confirmation dialog warns you of the risk.

### 🏋️ Movement-Specific Durations
| Movement | Base Rest |
|---|---|
| Squat / Deadlift | 3:00 (180s) — high CNS demand |
| Bench Press / OHP | 2:30 (150s) |

### 🎯 Minimal UI
Full black background, large countdown display, color-coded progress ring, and per-phase status labels — designed for readability under gym lighting.

---

## Implementation

| Component | Details |
|---|---|
| `ExerciseType` | Enum defining 4 movements, base durations, ATP lock constant |
| `TimerEngine` | `@MainActor ObservableObject` — async/await countdown loop, phase state machine, HRR check logic |
| `HealthKitManager` | `HKAnchoredObjectQuery` for real-time HR; initial fetch + continuous update handler |
| `HomeView` | Navigation list of 4 exercises |
| `TimerView` | Progress ring, countdown, HR display, skip button with confirmation dialogs |

**State machine phases:** `idle → atpLock → freeWindow → hrExtension(30) → ready`

---

## Requirements
- watchOS 26.2+
- Apple Watch with heart rate sensor
- HealthKit read permission (Heart Rate)

---

---

# IronTimer

**专为力量举训练者设计的 Apple Watch 休息管理器**

IronTimer 是一款独立 watchOS 应用，专注于深蹲、硬拉、卧推、推举四大杠铃复合动作的组间休息管理。区别于普通计时器，IronTimer 基于 ATP-PCr 恢复科学设定硬锁机制，从生理层面防止你在中枢神经恢复前过早开始下一组。

---

## IronTimer 的科学依据

### 为什么组间休息时间如此关键

大多数训练者要么休息太短（追求泵感），要么毫无规律（刷手机忘了时间）。两者都会严重损害最大力量输出。IronTimer 基于运动生理学的两大核心支柱构建：

#### 1. ATP-磷酸肌酸（PCr）再合成 — 物理硬限制
磷酸肌酸系统是大重量复合动作的首要能量来源。一组极限努力后，PCr 储量几乎耗尽。研究数据显示：
- 约 **30 秒**内恢复 **50%**
- 约 **90 秒**内恢复 **75%**
- 恢复至 **95% 以上**需要 3–5 分钟完整休息

这正是前 90 秒**强制硬锁**的原因——无例外，无法跳过。在这个窗口内开始下一组，无论你主观感觉多好，都必然导致力量下降。

#### 2. 心率恢复（HRR）— 安全兜底机制
心率是心血管系统和自主神经系统（ANS）压力的直接反映指标。倒计时结束后心率仍高于 120 bpm，说明系统性疲劳尚未消除——即便 PCr 已部分恢复，神经系统仍处于应激状态。IronTimer 通过 HealthKit 实时心率数据，在允许下一组前强制执行最低心脏恢复阈值。

#### 为什么是 120 bpm？
120 bpm 是运动科学文献中公认的阈值，代表"中等心血管压力"与"恢复区间"的分界线。低于此值时，大多数训练有素的运动员的交感神经激活已充分消退。

---

## 为什么 IronTimer 优于其他所有计时器

| 功能 | 普通计时器 | 心率类应用 | **IronTimer** |
|---|---|---|---|
| 基于科学的休息时长 | ❌ | ❌ | ✅ |
| ATP 硬锁（防止随意跳过） | ❌ | ❌ | ✅ |
| 实时心率恢复检测 | ❌ | 部分支持 | ✅ |
| 力量举专属预设 | ❌ | ❌ | ✅ |
| Apple Watch 独立运行 | ❌ | ❌ | ✅ |

**核心洞察：** 心率下降 ≠ 神经系统已恢复；计时器归零 ≠ ATP 已补足。IronTimer **同时**强制执行这两个条件——这是目前没有任何其他工具做到的。

---

## 核心功能

### ⚡ ATP 物理时间硬锁
每次休息的前 90 秒，"跳过"按钮强制禁用——无论你感觉多好。这是磷酸肌酸重新合成的物理时间需求。

### 💓 HRR 心率恢复安全机制
倒计时归零时，IronTimer 通过 HealthKit 实时读取心率。若心率仍高于 120 bpm，自动延长 30 秒并震动提醒。90 秒后主动跳过时也会进行心率检查，HR > 120 则弹出二次确认对话框。

### 🏋️ 动作专属时长
| 动作 | 基础休息 |
|---|---|
| 深蹲 / 硬拉 | 3:00（180秒）— CNS 消耗极大 |
| 卧推 / 推举 | 2:30（150秒）|

### 🎯 极简界面
纯黑背景、大字号倒计时、阶段联动进度环颜色，适配健身房强光环境。

---

## 技术实现

| 模块 | 说明 |
|---|---|
| `ExerciseType` | 枚举定义四大动作、基础时长、ATP 硬锁常量 |
| `TimerEngine` | `@MainActor ObservableObject`，async/await 驱动倒计时，相位状态机，HRR 检查逻辑 |
| `HealthKitManager` | `HKAnchoredObjectQuery` 实时心率查询，初始获取 + 持续更新双阶段查询 |
| `HomeView` | 动作选择列表 |
| `TimerView` | 进度环、倒计时、心率显示、跳过确认对话框 |

**状态机相位：** `idle → atpLock → freeWindow → hrExtension(30) → ready`

---

## 运行要求
- watchOS 26.2+
- 配备心率传感器的 Apple Watch
- HealthKit 心率读取权限
