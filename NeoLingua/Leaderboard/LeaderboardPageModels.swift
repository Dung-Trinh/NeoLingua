import Foundation

struct ScavengerHuntRanking {
    var scavengerHuntId: String
    var userPerformances: [UserTaskPerformance]
}

struct UserScore: Identifiable, Decodable {
    var id: String = UUID().uuidString
    let username: String
    let totalPoints: Double
}

struct CompetitiveScavengerHuntRanking: Identifiable {
    var id: String = UUID().uuidString
    let scavengerHunt: ScavengerHunt
    let userScores: [UserScore]
}
