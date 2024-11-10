import SwiftUI

struct LeaderboardPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: LeaderboardPageViewModelImpl
    
    var body: some View {
        VStack {
            Text("LeaderboardPage")
            Picker("LeadboardType", selection: $viewModel.selectedMode) {
                ForEach(LeaderboardMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
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
                Text("Weekly Ranking for rank").bold()
                Text("\(UserDefaults().getLevelOfLanguage().rawValue)")
            }
            LeaderboardView(userScores: viewModel.globalUserScores)
        }
    }
    
    @ViewBuilder
    private var scavengerHuntLeaderboard: some View {
        ScrollView {
            Text("your last competitive scavenger hunts")
            if viewModel.scavengerRankingList.count > 0 {
                ForEach(viewModel.scavengerRankingList) { ranking in
                    NavigationLink {
                        LeaderboardView(scavengerHunt: ranking.scavengerHunt, userScores: ranking.userScores)
                    } label: {
                        Text(ranking.scavengerHunt.title)
                    }
                }
                
            }
        }
    }
}

struct LeaderboardView: View {
    @State var scavengerHunt: ScavengerHunt? = nil
    @State var userScores: [UserScore] = []
    
    var body: some View {
        ScrollView {
            VStack {
                if let scavengerHunt = scavengerHunt {
                    Text(scavengerHunt.title).bold()
                    ForEach(scavengerHunt.taskLocations) { location in
                        Label(location.name, systemImage: "mappin.and.ellipse")
                    }
                }
                HStack {
                    Text("Platz")
                        .font(.headline)
                        .frame(width: 50, alignment: .leading)
                    Text("Name")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Punkte")
                        .font(.headline)
                        .frame(width: 80, alignment: .trailing)
                }
                .padding(.vertical, 4)
                .background(Color(.systemGray6))
                ForEach(0..<userScores.count) { index in
                    HStack {
                        Text("\(index + 1).")
                            .font(.headline)
                            .frame(width: 50, alignment: .leading)
                        Text(userScores[index].username)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(String(format: "%.2f", userScores[index].totalPoints))
                            .font(.subheadline)
                            .frame(width: 80, alignment: .trailing)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
}
