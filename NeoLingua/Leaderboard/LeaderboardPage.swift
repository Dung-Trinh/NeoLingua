import SwiftUI

struct LeaderboardPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: LeaderboardPageViewModelImpl
    
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
                    LeaderboardTile(
                        rank: "\(index + 1).",
                        username: userScores[index].username,
                        score: String(format: "%.2f", userScores[index].totalPoints)
                    )
                }
            }
        }.padding()
    }
}

struct LeaderboardTile: View {
    let rank: String
    let username: String
    let score: String

    
    var body: some View {
        HStack {
            Text(rank)
                .font(.headline)
                .frame(width: 50, alignment: .leading)
            Image(systemName:"person.crop.circle.fill")
                .resizable()
                .scaledToFill()
                .frame(width: 30, height: 30)
                .clipShape(Circle())
            Text(username)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(score)
                .font(.subheadline)
                .frame(width: 80, alignment: .trailing)
        }
        .padding(.vertical, 8)
    }
}
