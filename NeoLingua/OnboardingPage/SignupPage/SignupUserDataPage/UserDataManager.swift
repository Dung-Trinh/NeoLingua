import Firebase

protocol UserDataManager {
    func saveUserData(userData: ProfileData) async throws
    func fetchUserData() async throws -> ProfileData?
    
}

struct ProfileData {
    let name: String
    let learningGoals: [String]
    let interests: [String]
    let estimationOfDailyUse: Int
}

class UserDataManagerImpl: UserDataManager {
    let db = Firestore.firestore()
    
    func saveUserData(userData: ProfileData) async throws {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            print("userId not found")
            return
        }
        
        let data: [String: Any] = [
            "userId": userId,
            "name": userData.name,
            "learningGoals": userData.learningGoals,
            "interests": userData.interests,
            "estimationOfDailyUse": userData.estimationOfDailyUse
        ]
        
        try await db.collection("users").addDocument(data: data)
    }
    
    func fetchUserData() async throws -> ProfileData? {
        guard let userUid = UserDefaults.standard.string(forKey: "userId") else {
            print("userId not found")
            return nil
        }
                
        let snapshots = try await db.collection("users").whereField("uid", isEqualTo: userUid).getDocuments()
        guard let document = snapshots.documents.first else {
            return nil
        }
        
        let data = document.data()
        
        
        if let name = data["name"] as? String,
           let learningGoals = data["learningGoals"] as? [String],
           let interests = data["interests"] as? [String],
           let estimationOfDailyUse = data["estimationOfDailyUse"] as? Int {
            
            let profileData = ProfileData(
                name: name,
                learningGoals: learningGoals,
                interests: interests,
                estimationOfDailyUse: estimationOfDailyUse
            )
            return profileData
        } else {
            return nil
        }
    }
}
