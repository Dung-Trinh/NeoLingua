import Foundation

enum LeaderboardMode: String, CaseIterable, Identifiable {
    case globalScore
    case scavengerHunt
    
    var id: Self { self }
    
    var text: String {
        switch self {
            case .globalScore: "Globale Rangliste"
            case .scavengerHunt: "Scavenger Hunt Rangliste"
        }
    }
}

protocol LeaderboardPageViewModel: ObservableObject {

}

class LeaderboardPageViewModelImpl: LeaderboardPageViewModel {
    
    private let leaderboardService = LeaderboardService()
    @Published var selectedMode: LeaderboardMode = .globalScore
    @Published var globalUserScores: [UserScore] = []
    @Published var scavengerRankingList: [CompetitiveScavengerHuntRanking] = []
    @Published var isLoading: Bool = false

    private var userManager = UserDataManagerImpl()
    
    func fetchUserScores() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            globalUserScores = try await leaderboardService.fetchRankingForLevel()
            await fetchScavengerHuntScores()
        } catch {
            print("fetchUserScores error ", error.localizedDescription)
        }
    }
    
    func fetchScavengerHuntScores() async {
        do {
            let userProfile = try await userManager.fetchUserData()
            scavengerRankingList = try await leaderboardService.createRankingsForScavengerHuntId(scavengerHuntIds: userProfile.competitiveScavengerHuntIds)
            print("scavengerRankingList.count")
            print(scavengerRankingList.first?.userScores)
            print(scavengerRankingList.last?.userScores)
        } catch {
            print("fetchScavengerHuntScores error: ", error.localizedDescription)
        }
        
    }
}

struct ScavengerHuntRanking {
    var scavengerHuntId: String
    var userPerformances: [UserTaskPerformance]
}
