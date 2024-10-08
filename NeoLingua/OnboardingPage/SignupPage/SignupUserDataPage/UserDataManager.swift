import Firebase

protocol UserDataManager {
    func saveUserData(userData: ProfileData) async throws
    func fetchUserData() async throws -> ProfileData?
    
}

struct ProfileData {
    let name: String
    let learningGoals: [String]
    let estimationOfDailyUse: Int
}

class UserDataManagerImpl: UserDataManager {
    let db = Firestore.firestore()
    
    func saveUserData(userData: ProfileData) async throws {
        guard let userUid = UserDefaults.standard.string(forKey: "userUid") else {
            print("userUid not found")
            return
        }
        
        let data: [String: Any] = [
            "uid": userUid,
            "name": userData.name,
            "learningGoals": userData.learningGoals,
            "estimationOfDailyUse": userData.estimationOfDailyUse
        ]
        
        try await db.collection("users").addDocument(data: data)
    }
    
    func fetchUserData() async throws -> ProfileData? {
        guard let userUid = UserDefaults.standard.string(forKey: "userUid") else {
            print("userUid not found")
            return nil
        }
                
        let snapshots = try await db.collection("users").whereField("uid", isEqualTo: userUid).getDocuments()
        guard let document = snapshots.documents.first else {
            return nil
        }
        
        let data = document.data()
        
        
        if let name = data["name"] as? String,
           let learningGoals = data["learningGoals"] as? [String],
           let estimationOfDailyUse = data["estimationOfDailyUse"] as? Int {
            
            let profileData = ProfileData(name: name, learningGoals: learningGoals, estimationOfDailyUse: estimationOfDailyUse)
            return profileData
        } else {
            return nil
        }
    }
}
