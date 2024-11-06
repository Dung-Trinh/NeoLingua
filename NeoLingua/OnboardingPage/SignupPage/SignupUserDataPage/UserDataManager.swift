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
}
