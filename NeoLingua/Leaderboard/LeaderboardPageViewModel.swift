import Foundation

enum LeaderboardMode: String, CaseIterable, Identifiable {
    case globalScore
    case scavengerHunt
    
    var id: Self { self }
}

protocol LeaderboardPageViewModel: ObservableObject {

}

class LeaderboardPageViewModelImpl: LeaderboardPageViewModel {
    
    private let leaderboardService = LeaderboardService()
    @Published var selectedMode: LeaderboardMode = .scavengerHunt
    @Published var userScores: [UserScore] = []
    
    func fetchUserScores() async {
        do {
            userScores = try await leaderboardService.fetchRankingForLevel()
        } catch {
            print("fetchUserScores error ", error.localizedDescription)
        }
    }
}

struct ScavengerHuntRanking {
    var scavengerHuntId: String
    var userPerformances: [UserTaskPerformance]
}
