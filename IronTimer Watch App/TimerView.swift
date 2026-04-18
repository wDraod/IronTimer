import SwiftUI

struct TimerView: View {
    @ObservedObject var engine: TimerEngine
    let exercise: ExerciseType

    @Environment(\.dismiss) private var dismiss
    @State private var showExitConfirm = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 6) {
                // 进度环 + 时间
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 6)

                    Circle()
                        .trim(from: 0, to: engine.progressFraction)
                        .stroke(ringColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: engine.progressFraction)

                    VStack(spacing: 2) {
                        Text(timeString)
                            .font(.system(size: 44, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.6)

                        Text(phaseLabel)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(phaseColor)
                    }
                }
                .frame(width: 140, height: 140)

                // 心率
                if engine.currentHR > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.red)
                        Text("\(engine.currentHR) bpm")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }

                // 跳过按钮
                Button(action: { engine.requestSkip() }) {
                    Text(engine.phase == .ready ? "下一组 ✓" : "跳过")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(skipButtonColor)
                        .foregroundColor(engine.isSkipEnabled ? .black : Color(white: 0.4))
                        .clipShape(Capsule())
                }
                .disabled(!engine.isSkipEnabled && engine.phase != .ready)
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 8)
        }
        .navigationTitle(exercise.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { showExitConfirm = true }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .confirmationDialog("退出计时？", isPresented: $showExitConfirm) {
            Button("确认退出", role: .destructive) {
                engine.reset()
                dismiss()
            }
            Button("继续休息", role: .cancel) { }
        } message: {
            Text("计时将被中断，确认退出吗？")
        }
        .onAppear {
            engine.start(exercise: exercise)
        }
        // Case 3：freeWindow 跳过但 HR > 120
        .alert("心率仍然偏高", isPresented: .init(
            get: { engine.showHighHRSkipConfirm },
            set: { if !$0 { engine.cancelSkip() } }
        )) {
            Button("确认跳过", role: .destructive) { engine.confirmSkip() }
            Button("继续休息", role: .cancel) { engine.cancelSkip() }
        } message: {
            Text("当前 HR \(engine.currentHR) bpm，您可能还需要再缓缓。确认要进入下一组吗？")
        }
        // Case 4：自然归零 HR > 120，已自动延长
        .alert("系统尚未恢复", isPresented: .init(
            get: { engine.showHRExtensionAlert },
            set: { if !$0 { engine.dismissHRExtensionAlert() } }
        )) {
            Button("知道了", role: .cancel) { engine.dismissHRExtensionAlert() }
        } message: {
            Text("当前 HR \(engine.currentHR) bpm 仍然较高，已自动为您延长 30 秒，请继续休息。")
        }
    }

    // MARK: - Helpers

    private var timeString: String {
        let m = engine.remaining / 60
        let s = engine.remaining % 60
        return String(format: "%d:%02d", m, s)
    }

    private var phaseLabel: String {
        switch engine.phase {
        case .idle:               return ""
        case .atpLock:            return "ATP 重组中"
        case .freeWindow:         return "可进入下一组"
        case .hrExtension:        return "延长恢复中"
        case .ready:              return "准备好了！"
        }
    }

    private var phaseColor: Color {
        switch engine.phase {
        case .atpLock:     return .orange
        case .freeWindow:  return Color(red: 0.4, green: 1.0, blue: 0.4)
        case .hrExtension: return .red
        case .ready:       return .yellow
        default:           return .clear
        }
    }

    private var ringColor: Color {
        switch engine.phase {
        case .atpLock:     return .orange
        case .freeWindow:  return Color(red: 0.4, green: 1.0, blue: 0.4)
        case .hrExtension: return .red
        case .ready:       return .yellow
        default:           return .white
        }
    }

    private var skipButtonColor: Color {
        guard engine.isSkipEnabled else {
            return Color(white: 0.2)
        }
        switch engine.phase {
        case .hrExtension: return .red.opacity(0.8)
        case .ready:       return .yellow
        default:           return Color(red: 0.4, green: 1.0, blue: 0.4)
        }
    }
}
