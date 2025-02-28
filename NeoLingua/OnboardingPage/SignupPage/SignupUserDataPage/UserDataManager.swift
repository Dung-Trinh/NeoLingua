import Firebase

protocol UserDataManager {
    func saveUserData(userData: ProfileData) async throws
    func fetchUserData() async throws -> ProfileData
    func addCompetitiveScavengerHuntId(scavengerHuntId: String) async throws
}

struct ProfileData: Codable {
    let username: String
    let learningGoals: [String]
    let interests: [String]
    let estimationOfDailyUse: Int
    var competitiveScavengerHuntIds: [String] = []
}

class UserDataManagerImpl: UserDataManager {
    private let firebaseDataManager = FirebaseDataManagerImpl()
    
    func saveUserData(userData: ProfileData) async throws {
        let userId = UserDefaults().getUserId()
        try firebaseDataManager.saveUserData(userData: userData, userId: userId)
    }
    
    func fetchUserData() async throws -> ProfileData {
        let userId = UserDefaults().getUserId()
        let profileData = try await firebaseDataManager.fetchUserData(userId: userId)
        return profileData
    }
    
    func addCompetitiveScavengerHuntId(scavengerHuntId: String) async throws {
        let userId = UserDefaults().getUserId()
        try await firebaseDataManager.addCompetitiveScavengerHuntId(
            scavengerHuntId: scavengerHuntId,
            userId: userId
        )
    }
}
