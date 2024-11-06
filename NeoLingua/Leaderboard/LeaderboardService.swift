import Foundation
import Firebase

struct UserScore: Identifiable {
    let id = UUID()
    let username: String
    let points: Double
}

class LeaderboardService {
    private let db = Firestore.firestore()
    
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
            let score = UserScore(username: username, points: points)
            
            results.append(score)
        }
        return results
    }
}
