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
    var selectedMode: LeaderboardMode { get set }
    var isLoading: Bool { get }
    var scavengerRankingList: [CompetitiveScavengerHuntRanking] { get }
    var globalUserScores: [UserScore] { get }
    
    func fetchScavengerHuntScores() async
    func fetchUserScores() async
}

class LeaderboardPageViewModelImpl: LeaderboardPageViewModel {
    private let leaderboardService: LeaderboardService = LeaderboardServiceImpl()
    private var userManager = UserDataManagerImpl()

    @Published var selectedMode: LeaderboardMode = .globalScore
    @Published var globalUserScores: [UserScore] = []
    @Published var scavengerRankingList: [CompetitiveScavengerHuntRanking] = []
    @Published var isLoading: Bool = false
    
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
            scavengerRankingList = try await leaderboardService.createRankingsForScavengerHuntId(
                scavengerHuntIds: userProfile.competitiveScavengerHuntIds
            )
            print("scavengerRankingList.count")
            print(scavengerRankingList.first?.userScores)
        } catch {
            print("fetchScavengerHuntScores error: ", error.localizedDescription)
        }
    }
}
