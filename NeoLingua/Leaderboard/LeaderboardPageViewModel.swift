import Foundation

protocol LeaderboardPageViewModel: ObservableObject {

}

class LeaderboardPageViewModelImpl: LeaderboardPageViewModel {
    
    
}

struct ScavengerHuntRanking {
    var scavengerHuntId: String
    var userPerformances: [UserTaskPerformance]
}
