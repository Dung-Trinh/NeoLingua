import SwiftUI

struct ChallengePage: View {
    var body: some View {
        VStack {
            Text("Task board").font(.title).bold().multilineTextAlignment(.leading)
            ScrollView {
                VStack(alignment: .leading, spacing: Styleguide.Margin.medium) {
                    VStack {
                        Text("Weekly tasks")
                            .font(.system(size: 24, weight: .semibold))
                        TaskTile(viewModel: .init(taskTitle: "Complete 3 scavenger hunts", iconName: "map.fill", currentProgress: 1, totalProgress: 3))
                    }
                    VStack {
                        Text("Today's tasks")
                            .font(.system(size: 24, weight: .semibold))
                        TaskTile(viewModel: .init(taskTitle: "Complete 3 listening comprehension exercises", iconName: "ear.badge.waveform", currentProgress: 1, totalProgress: 2))
                        TaskTile(viewModel: .init(taskTitle: "Find 5 vocabulary in SnapVocabulary", iconName: "list.bullet.rectangle", currentProgress: 4, totalProgress: 6))
                    }
                    VStack {
                        Text("Recommendations for your learning goal: ")
                            .font(.system(size: 24, weight: .semibold))
                        TaskTile(viewModel: .init(taskTitle: "Practice a conversation in the hotel.", iconName: "bubble.left.and.text.bubble.right", currentProgress: 0, totalProgress: 1))
                    }
                }
                .padding()
            }
        }
    }
}
