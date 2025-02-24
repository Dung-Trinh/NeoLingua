import SwiftUI

struct LeaderboardPage<ViewModel>: View where ViewModel: LeaderboardPageViewModel {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Text("Ranking").font(.title).bold()
            Picker("LeadboardType", selection: $viewModel.selectedMode) {
                ForEach(LeaderboardMode.allCases) { mode in
                    Text(mode.text).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            ScrollView {
                switch viewModel.selectedMode {
                    case .globalScore: gloabalLeaderboard
                    case .scavengerHunt: scavengerHuntLeaderboard
                }
            }
        }
        .padding()
        .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
        .onAppear {
            Task {
                await viewModel.fetchUserScores()
            }
        }
    }
    
    @ViewBuilder
    private var gloabalLeaderboard: some View {
        VStack {
            HStack {
                Text("Wöchentliche Rangliste für Rang")
                Text("\(UserDefaults().getLevelOfLanguage().rawValue)")
            }.font(.headline).bold()
            LeaderboardView(userScores: viewModel.globalUserScores)
        }
    }
    
    @ViewBuilder
    private var scavengerHuntLeaderboard: some View {
        ScrollView {
            Text("Deine letzten Schnitzeljagden").font(.headline).bold().padding()
            if viewModel.scavengerRankingList.count > 0 {
                ForEach(viewModel.scavengerRankingList) { ranking in
                    NavigationLink {
                        LeaderboardView(
                            scavengerHunt: ranking.scavengerHunt,
                            userScores: ranking.userScores
                        )
                    } label: {
                        Text(ranking.scavengerHunt.title)
                    }
                }
            }
        }
    }
}
