import Foundation

enum ExerciseType: String, CaseIterable, Identifiable {
    case squat      = "深蹲"
    case deadlift   = "硬拉"
    case bench      = "卧推"
    case ohp        = "推举"

    var id: String { rawValue }

    /// 基础倒计时（秒）
    var baseDuration: Int {
        switch self {
        case .squat, .deadlift: return 180   // CNS 消耗极大
        case .bench, .ohp:      return 150
        }
    }

    /// ATP 硬锁时长（秒）— 不可跳过窗口
    static let atpLockDuration: Int = 90

    var emoji: String {
        switch self {
        case .squat:    return "🦵"
        case .deadlift: return "🏋️"
        case .bench:    return "🧰"
        case .ohp:      return "🦾"
        }
    }

    var displayName: String { rawValue }
}
