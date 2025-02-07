import Foundation
import SwiftUI
import Firebase
import FirebaseStorage

class FirebaseDataManager {
    private let db = Firestore.firestore()

    func generateDownloadURL(selectedImage: UIImage?) async -> String {
        guard let imageData = selectedImage?.jpegData(compressionQuality: 0.8) else { return "" }
        if let downloadURL = await uploadImageToFileStorage(imageData: imageData) {
            return downloadURL
        }
        return ""
    }
    
    func uploadImageToFileStorage(imageData: Data) async -> String? {
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("images/\(UUID().uuidString).jpg")
        let metadata = try? await imageRef.putDataAsync(imageData)
        let downloadURL = try? await imageRef.downloadURL()
        return downloadURL?.absoluteString
    }
    
    func fetchSnapVocabularyTasks() async throws -> [SnapVocabularyTask] {
        let snapshots = try await db.collection("imageBasedTasks").getDocuments()
        let allTasks = snapshots.documents.compactMap { document in
            try? document.data(as: SnapVocabularyTask.self)
        }
        
        return allTasks
    }
    
    func queryLocations(
        centerLatitude: Double,
        centerLongitude: Double,
        radiusInKm: Double
    ) async throws -> [QueryDocumentSnapshot] {
        print("centerLatitude: ", centerLatitude)
        print("centerLongitude: ", centerLongitude)
        
        //Berechnung der Bounding Box
        let rangeLat = radiusInKm / 110.574
        let rangeLon = radiusInKm / (111.320 * cos(centerLatitude * .pi / 180))
        
        let minLat = centerLatitude - rangeLat
        let maxLat = centerLatitude + rangeLat
        let minLon = centerLongitude - rangeLon
        let maxLon = centerLongitude + rangeLon
        
        print("minLat ", minLat)
        print("maxLat ", maxLat)
        print("minLon ", minLon)
        print("maxLon ", maxLon)
        
        let query = db.collection("imageBasedTasks")
            .whereField("coordinates.longitude", isGreaterThanOrEqualTo: minLon)
            .whereField("coordinates.longitude", isLessThanOrEqualTo: maxLon)
            .whereField("coordinates.latitude", isGreaterThanOrEqualTo: minLat)
            .whereField("coordinates.latitude", isLessThanOrEqualTo: maxLat)
        
        let querySnapshot = try await query.getDocuments()
        return querySnapshot.documents
    }

    
    func saveUserData(userData: ProfileData, userId: String) throws {
        try db.collection("users").document(userId).setData(from: userData)
    }
    
    func fetchUserData(userId: String) async throws -> ProfileData {
        let document = try await db.collection("users").document(userId).getDocument()
        let profileData = try document.data(as: ProfileData.self)
        return profileData
    }
    
    func addCompetitiveScavengerHuntId(scavengerHuntId: String, userId: String) async throws {
        let profileRef = db.collection("users").document(userId)
        let documentSnapshot = try await profileRef.getDocument()
        
        var profile = try documentSnapshot.data(as: ProfileData.self)
        profile.competitiveScavengerHuntIds.append(scavengerHuntId)
        try profileRef.setData(from: profile)
    }
}
