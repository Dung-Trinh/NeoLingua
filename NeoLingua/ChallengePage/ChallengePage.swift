import SwiftUI

struct ChallengePage: View {
    var body: some View {
        VStack {
            Text("Aufgaben").font(.title).bold().multilineTextAlignment(.leading)
            ScrollView {
                VStack(alignment: .leading, spacing: Styleguide.Margin.large) {
                    VStack {
                        Text("Wöchentliche Aufgaben").font(.title3)
                        TaskTile(viewModel: .init(taskTitle: "Complete 3 scavenger hunts", iconName: "map.fill", currentProgress: 1, totalProgress: 3))
                    }
                    VStack {
                        Text("Heutige Aufgaben").font(.title3)
                            .font(.system(size: 24, weight: .semibold))
                        TaskTile(viewModel: .init(taskTitle: "Complete 3 listening comprehension exercises", iconName: "ear.badge.waveform", currentProgress: 1, totalProgress: 2))
                        TaskTile(viewModel: .init(taskTitle: "Find 5 vocabulary in SnapVocabulary", iconName: "list.bullet.rectangle", currentProgress: 4, totalProgress: 6))
                    }
                    VStack {
                        Text("Empfehlungen für Ihr Lernziel")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                        TaskTile(viewModel: .init(taskTitle: "Practice a conversation in the hotel.", iconName: "bubble.left.and.text.bubble.right", currentProgress: 0, totalProgress: 1))
                    }
                }
                
            }
        }.padding()
    }
}
