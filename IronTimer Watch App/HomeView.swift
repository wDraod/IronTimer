import SwiftUI

struct HomeView: View {
    @StateObject private var engine = TimerEngine()
    @State private var selectedExercise: ExerciseType? = nil

    var body: some View {
        NavigationStack {
            List(ExerciseType.allCases) { exercise in
                NavigationLink(value: exercise) {
                    Label {
                        Text(exercise.displayName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    } icon: {
                        Text(exercise.emoji)
                            .font(.system(size: 22))
                    }
                }
                .listRowBackground(Color(white: 0.12))
            }
            .listStyle(.plain)
            .navigationTitle("IronTimer")
            .navigationDestination(for: ExerciseType.self) { exercise in
                TimerView(engine: engine, exercise: exercise)
            }
        }
        .background(Color.black)
    }
}

#Preview {
    HomeView()
}
