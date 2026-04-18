import Foundation
import Combine
import WatchKit

/// 倒计时状态机
enum TimerPhase: Equatable {
    case idle                   // 未启动
    case atpLock                // 0...90s：硬锁，禁止跳过
    case freeWindow             // 90s 之后：允许跳过
    case hrExtension(Int)       // 心率未达标，延长 N 秒
    case ready                  // 完成，允许下一组
}

@MainActor
final class TimerEngine: ObservableObject {

    // MARK: - Published State
    @Published private(set) var phase: TimerPhase = .idle
    @Published private(set) var remaining: Int = 0      // 剩余秒数
    @Published private(set) var totalDuration: Int = 0  // 本轮总秒数（用于进度环）
    @Published private(set) var peakHR: Int = 0         // 峰值心率（启动时记录）
    @Published private(set) var currentHR: Int = 0      // 实时心率

    /// Case 3：主动跳过时 HR > 120，需要用户二次确认
    @Published private(set) var showHighHRSkipConfirm = false
    /// Case 4：自然归零时 HR > 120，触发延长，告知用户原因
    @Published private(set) var showHRExtensionAlert = false

    // MARK: - Dependencies
    var heartRateProvider: HeartRateProvider = HealthKitManager.shared

    // MARK: - Private
    private var countdownTask: Task<Void, Never>?
    private var exercise: ExerciseType?

    // MARK: - Public Interface

    func start(exercise: ExerciseType) {
        countdownTask?.cancel()
        self.exercise = exercise

        // 启动实时心率查询
        HealthKitManager.shared.startHeartRateQuery()

        // 记录峰值心率（此时刚做完一组，应为较高值）
        peakHR = heartRateProvider.latestHR
        currentHR = peakHR

        let base = exercise.baseDuration
        totalDuration = base
        remaining = base
        phase = .atpLock

        countdownTask = Task { await runCountdown() }
    }

    /// 用户点击跳过按钮（仅 freeWindow / hrExtension 阶段）
    func requestSkip() {
        guard phase == .freeWindow || isHRExtension(phase) else { return }

        if isHRExtension(phase) {
            // 延长段：用户已知情并确认过，直接放行
            finish()
            return
        }

        // freeWindow：先查 HR，决定是否需要二次确认
        let hr = heartRateProvider.latestHR
        currentHR = hr
        if hr > 120 {
            // HR 偏高，弹确认框，倒计时继续在后台跑
            showHighHRSkipConfirm = true
        } else {
            // HR 正常，直接完成
            countdownTask?.cancel()
            finish()
        }
    }

    /// 用户在高 HR 确认框中选择"确认跳过"
    func confirmSkip() {
        showHighHRSkipConfirm = false
        countdownTask?.cancel()
        finish()
    }

    /// 用户在高 HR 确认框中选择"取消"，倒计时继续
    func cancelSkip() {
        showHighHRSkipConfirm = false
    }

    /// 用户在 HR 延长提示框中点击"知道了"
    func dismissHRExtensionAlert() {
        showHRExtensionAlert = false
    }

    // MARK: - Countdown Loop

    private func runCountdown() async {
        while remaining > 0 {
            try? await Task.sleep(for: .seconds(1))
            if Task.isCancelled { return }

            remaining -= 1

            // 更新心率（真实接入后由 HealthKitManager 推送）
            currentHR = heartRateProvider.latestHR

            // 更新阶段
            updatePhase()
        }

        // 倒计时归零 → 执行 HRR 检查
        await checkHRR()
    }

    private func updatePhase() {
        guard let ex = exercise else { return }
        let elapsed = ex.baseDuration - remaining   // 注意：延长段不影响 atpLock 判断

        if case .hrExtension = phase { return }     // 延长中不重新判断 atpLock

        if elapsed < ExerciseType.atpLockDuration {
            phase = .atpLock
        } else {
            phase = .freeWindow
        }
    }

    /// 倒计时归零后的 HRR 安全检查
    private func checkHRR() async {
        let hr = heartRateProvider.latestHR
        currentHR = hr

        if hr > 120 {
            // 触发延长，震动警告，并通知 UI 弹提示
            WKInterfaceDevice.current().play(.notification)
            phase = .hrExtension(30)
            totalDuration = 30
            remaining = 30
            showHRExtensionAlert = true

            countdownTask = Task { await runExtension() }
        } else {
            finish()
        }
    }

    /// 延长段倒计时
    private func runExtension() async {
        while remaining > 0 {
            try? await Task.sleep(for: .seconds(1))
            if Task.isCancelled { return }
            remaining -= 1
            currentHR = heartRateProvider.latestHR
        }
        finish()
    }

    private func finish() {
        countdownTask?.cancel()
        remaining = 0
        phase = .ready
        WKInterfaceDevice.current().play(.success)
    }

    func reset() {
        countdownTask?.cancel()
        HealthKitManager.shared.stopHeartRateQuery()
        phase = .idle
        remaining = 0
        totalDuration = 0
        exercise = nil
    }

    // MARK: - Helpers

    var isSkipEnabled: Bool {
        phase == .freeWindow || isHRExtension(phase)
    }

    var progressFraction: Double {
        guard totalDuration > 0 else { return 0 }
        return 1.0 - Double(remaining) / Double(totalDuration)
    }

    private func isHRExtension(_ p: TimerPhase) -> Bool {
        if case .hrExtension = p { return true }
        return false
    }
}

// MARK: - Heart Rate Provider Protocol

protocol HeartRateProvider {
    var latestHR: Int { get }
}

