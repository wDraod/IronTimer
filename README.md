# IronTimer

**A hardcore rest timer for powerlifters — built for Apple Watch**

IronTimer is a standalone watchOS app designed exclusively for the Big Four barbell movements: Squat, Deadlift, Bench Press, and Overhead Press. Unlike generic timers that only track heart rate, IronTimer enforces ATP-PCr recovery science with a hard lock mechanism, preventing you from cutting rest short before your CNS is ready.

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
