import Foundation
import Firebase

protocol LeaderboardService {
    func addPointsForLevel(points: Double) async throws
    func createRankingsForScavengerHuntId(scavengerHuntIds: [String]) async throws -> [CompetitiveScavengerHuntRanking]
    func addPointToCompetitiveScavengerHunt(scavengerHuntId: String, points: Double) async throws
    func fetchUserScoresRanking(forHuntId huntId: String) async throws -> [UserScore]?
    func fetchRankingForLevel() async throws -> [UserScore]
}

class LeaderboardServiceImpl: LeaderboardService {
    private let db = Firestore.firestore()
    private let scavengerHuntManager = ScavengerHuntManagerImpl()
    
    func addPointsForLevel(points: Double) async throws {
        let languageLevel = UserDefaults().getLevelOfLanguage().rawValue
        let userId = UserDefaults().getUserId()
        let username = UserDefaults().getUsername()
        
        let levelCollectionRef = db.collection("ranking_\(languageLevel)")
        let userRef = levelCollectionRef.document(userId)
        
        try await db.runTransaction { transaction, errorPointer in
            let userDoc: DocumentSnapshot
            do {
                userDoc = try transaction.getDocument(userRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return
            }
            
            if userDoc.exists {
                let currentPoints = userDoc.data()?["totalPoints"] as? Double ?? 0
                let newTotalPoints = currentPoints + points
                transaction.updateData([
                    "totalPoints": newTotalPoints.twoDecimals,
                ], forDocument: userRef)
            } else {
                transaction.setData([
                    "userId": userId,
                    "username": username,
                    "totalPoints": points,
                ], forDocument: userRef)
            }
            return nil
        }
    }
    
    func createRankingsForScavengerHuntId(scavengerHuntIds: [String]) async throws -> [CompetitiveScavengerHuntRanking] {
        var result: [CompetitiveScavengerHuntRanking] = []
        
        for id in scavengerHuntIds {
            if let ranking = try await fetchUserScoresRanking(forHuntId: id),
               let scavengerHunt = try await scavengerHuntManager.fetchScavengerHuntById(withId: id) {
                result.append(.init(scavengerHunt: scavengerHunt, userScores: ranking))
                print("ranking + hunt")
            }
        }
        
        return result
    }
    
    func addPointToCompetitiveScavengerHunt(scavengerHuntId: String, points: Double) async throws {
        let userId = UserDefaults().getUserId()
        let username = UserDefaults().getUsername()
        
        let userScoreRef = db.collection("competitiveScavengerHuntRankings").document(scavengerHuntId).collection("userScores").document(userId)
        
        try await userScoreRef.setData([
            "userId": userId,
            "username": username,
            "totalPoints": points,
        ])
    }
    
    func fetchUserScoresRanking(forHuntId huntId: String) async throws -> [UserScore]? {
        let userScoresRef = db.collection("competitiveScavengerHuntRankings").document(huntId).collection("userScores")
        let snapshot = try await userScoresRef.order(by: "totalPoints", descending: true).getDocuments()
        let userScores: [UserScore] = try snapshot.documents.compactMap { document in
            try document.data(as: UserScore.self)
        }
        print("userScores.count")
        print(userScores.count)
        return userScores
    }
    
    func fetchRankingForLevel() async throws -> [UserScore] {
        let languageLevel = UserDefaults().getLevelOfLanguage().rawValue
        let levelCollectionRef = Firestore.firestore().collection("ranking_\(languageLevel)")
        
        let querySnapshot = try await levelCollectionRef
            .order(by: "totalPoints", descending: true)
            .getDocuments()
        
        var results: [UserScore] = []
        for document in querySnapshot.documents {
            let username = document.data()["username"] as? String ?? ""
            let points = document.data()["totalPoints"] as? Double ?? 0
            let score = UserScore(username: username, totalPoints: points)
            
            results.append(score)
        }
        return results
    }
}
