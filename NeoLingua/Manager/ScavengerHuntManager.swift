import Foundation
import SwiftOpenAI
import Alamofire
import GoogleMaps
import Firebase

protocol ScavengerHuntManager {
    
}

class ScavengerHuntManagerImpl: TaskManager, ScavengerHuntManager {
    private let locationManager = LocationManager()
    private let db = Firestore.firestore()
    
    func generateScavengerHuntNearMe(radius: Int, taskLocationAmount: Int = 1) async throws -> ScavengerHunt {
        if CommandLine.arguments.contains("--useMockData") {
            return TestData.scavengerHunt
        }
        
        locationManager.requestLocation()
        
        guard let location = locationManager.lastKnownLocation else {
            print("no location found")
            throw NSError(domain: "no location found", code: 400)
        }
        print("currentLocation:", location)
        let url = "https://us-central1-neolingua.cloudfunctions.net/createScavengerHunt"
        let parameters: [String: Any] = [
            "latitude": location.latitude,
            "longitude": location.longitude,
            "radius": radius,
            "taskLocationAmount": taskLocationAmount
        ]
        
        let headers: HTTPHeaders = [
            "x-api-key": ProdENV().SCAVENGER_HUNT_SERVICE_API_KEY
        ]
        
        let response = try await AF.request(url, parameters: parameters, headers: headers)
            .serializingString()
            .value
                
        guard let data = response.data(using: .utf8) else {
            throw "Failed to convert JSON string to Data."
        }
        
        let scavengerHunt = try JSONDecoder().decode(ScavengerHuntResponse.self, from: data)
        
        print("Decoded Data: \(scavengerHunt)")
        return scavengerHunt.scavengerHunt
    }
    
    func fetchCompetitiveScavengerHunts() async throws -> [ScavengerHunt] {
        let snapshot = try await db.collection("competitiveScavengerHunt").getDocuments()
        let scavengerHunts: [ScavengerHunt] = try snapshot.documents.compactMap { document in
            try document.data(as: ScavengerHunt.self)
        }
        
        return scavengerHunts
    }
    
    func fetchScavengerHuntById(withId id: String) async throws -> ScavengerHunt? {
        let snapshot = try await db.collection("competitiveScavengerHunt")
            .whereField("id", isEqualTo: id)
            .getDocuments()
        
        guard let document = snapshot.documents.first else {
            throw "fetchScavengerHuntById document not found"
        }
        
        let scavengerHunt = try document.data(as: ScavengerHunt.self)
        return scavengerHunt
    }
    
    func saveScavengerHuntForRanking(scavengerHunt: ScavengerHunt) async throws {
        try db.collection("competitiveScavengerHunt").document(scavengerHunt.id).setData(from: scavengerHunt)
    }
    
    func saveScavengerHuntState(state: ScavengerHuntState) async throws {
        try db.collection("scavengerHuntState").addDocument(from: state)
    }
    
    func fetchScavengerHuntState(scavengerHuntId: String) async throws -> ScavengerHuntState {
        let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
        let query = db.collection("scavengerHuntState")
            .whereField("scavengerHuntId", isEqualTo: scavengerHuntId)
            .whereField("userId", isEqualTo: userId)
        
        let snapshot = try await query.getDocuments()
        
        guard let document = snapshot.documents.first else {
            throw "No scavenger hunt state found."
        }
        
        let scavengerHuntState = try document.data(as: ScavengerHuntState.self)
        return scavengerHuntState
    }
}
