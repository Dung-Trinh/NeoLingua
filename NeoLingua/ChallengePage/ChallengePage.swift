import SwiftUI

struct ChallengePage<ViewModel>: View where ViewModel: ChallengePageViewModel {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Text("Aufgaben")
                .font(.title)
                .bold()
                .multilineTextAlignment(.leading)
            ScrollView {
                VStack(alignment: .leading, spacing: Styleguide.Margin.large) {
                    VStack {
                        Text("Wöchentliche Aufgaben").font(.title3)
                        ForEach(viewModel.weeklyChallenge) { taskVM in
                            TaskTile(viewModel: taskVM)
                        }
                    }
                    VStack {
                        Text("Heutige Aufgaben").font(.title3)
                            .font(.system(size: 24, weight: .semibold))
                        ForEach(viewModel.todaysChallenge) { taskVM in
                            TaskTile(viewModel: taskVM)
                        }
                    }
                    VStack {
                        Text("Empfehlungen für Ihr Lernziel")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                        ForEach(viewModel.recommendationsForLearningGoal) { taskVM in
                            TaskTile(viewModel: taskVM)
                        }
                    }
                }
            }
        }
        .padding()
    }
}
