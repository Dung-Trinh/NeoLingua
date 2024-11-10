import Firebase

protocol UserDataManager {
    func saveUserData(userData: ProfileData) async throws
    func fetchUserData() async throws -> ProfileData
    
}

struct ProfileData: Codable {
    let username: String
    let learningGoals: [String]
    let interests: [String]
    let estimationOfDailyUse: Int
    var competitiveScavengerHuntIds: [String] = []
}

class UserDataManagerImpl: UserDataManager {
    let db = Firestore.firestore()
    
    func saveUserData(userData: ProfileData) async throws {
        let userId = UserDefaults().getUserId()
        try db.collection("users").document(userId).setData(from: userData)
    }
    
    func fetchUserData() async throws -> ProfileData {
        let userId = UserDefaults().getUserId()
        let document = try await db.collection("users").document(userId).getDocument()
        
        let profileData = try document.data(as: ProfileData.self)
        return profileData
    }
    
    func addCompetitiveScavengerHuntId(scavengerHuntId: String) async throws {
        let userId = UserDefaults().getUserId()
        let profileRef = db.collection("users").document(userId)
        let documentSnapshot = try await profileRef.getDocument()
        
        var profile = try documentSnapshot.data(as: ProfileData.self)
        profile.competitiveScavengerHuntIds.append(scavengerHuntId)
        try profileRef.setData(from: profile)
    }
}
