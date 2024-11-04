import Foundation
import SwiftOpenAI
import Alamofire
import GoogleMaps
import Firebase

struct TaskPrompt: Codable {
    let vocabularyTraining: String?
    let listeningComprehension: String?
    let conversationSimulation: String?
}

struct Location: Codable, Hashable{
    let latitude: Double
    let longitude: Double
}

struct TaskLocation: Codable, Identifiable {
    let id: String
    let name: String
    let type: String
    let location: Location
    let taskPrompt: TaskPrompt
    let photoClue: String
    let photoObject: String
    var performance: LocationTaskPerformance? = nil
    
    init(name: String, type: String, location: Location, taskPrompt: TaskPrompt, photoClue: String, photoObject: String) {
        self.id = UUID().uuidString
        self.name = name
        self.type = type
        self.location = location
        self.taskPrompt = taskPrompt
        self.photoClue = photoClue
        self.photoObject = photoObject
    }
}

struct ScavengerHunt: Codable {
    let id: String
    let introduction: String
    var taskLocations: [TaskLocation]
    var scavengerHuntState: ScavengerHuntState? = nil
    
    func isHuntComplete() -> Bool {
        guard let scavengerHuntState = scavengerHuntState else {
            return false
        }
        let isDone = true
        for performance in scavengerHuntState.locationTaskPerformance {
            if performance.performance.didFoundObject == nil {
                return false
            }
        }
        return isDone
    }
}

struct ScavengerHuntState: Codable {
    let scavengerHuntId: String
    let userId: String
    var isCompleted: Bool
    var locationTaskPerformance: [LocationTaskPerformance]
    
    init(scavengerHunt: ScavengerHunt) {
        self.scavengerHuntId = scavengerHunt.id
        userId = UserDefaults.standard.string(forKey: "userId") ?? ""
        isCompleted = false
        locationTaskPerformance = []
        for location in scavengerHunt.taskLocations {
            var performance = UserTaskPerformance(userId: userId,taskId: "")
            let performanceParameter = TaskPerformancetParameter()
            if location.taskPrompt.vocabularyTraining != nil {
                performance.vocabularyTraining = performanceParameter
            }
            
            if location.taskPrompt.listeningComprehension != nil {
                performance.listeningComprehension = performanceParameter
            }
            
            if location.taskPrompt.conversationSimulation != nil {
                performance.conversationSimulation = performanceParameter
            }
            
            let locationpPerformance = LocationTaskPerformance(
                locationId: location.id,
                performance: performance
            )
            locationTaskPerformance.append(locationpPerformance)
        }
    }
}

struct LocationTaskPerformance: Codable{
    let locationId: String
    var performance: UserTaskPerformance
}

struct ScavengerHuntResponse: Codable{
    let scavengerHunt: ScavengerHunt
}

class ScavengerHuntManager: TaskManager {
    let assistantID = ProdENV().TASK_ASSISTANT_ID
    let locationManager = LocationManager()
    let db = Firestore.firestore()
    
    func fetchScavengerHuntNearMe() async throws -> ScavengerHunt {
        if CommandLine.arguments.contains("--useMockData") {
            return TestData.scavengerHunt
        }
        
        locationManager.requestLocation()
        
        guard let location = locationManager.lastKnownLocation else {
            print("no location found")
            throw NSError(domain: "no location found", code: 400)
        }
        print("currentLocation:", location)
        let url = "http://localhost:3000/locationAgent"
        let parameters: [String: Any] = [
            "latitude": location.latitude,
            "longitude": location.longitude
        ]
        
        do {
            let response = try await AF.request(url, parameters: parameters)
                .serializingString()
                .value
            
            guard let data = response.data(using: .utf8) else {
                throw "Failed to convert JSON string to Data."
            }
            
            let scavengerHunt = try JSONDecoder().decode(ScavengerHuntResponse.self, from: data)
            
            print("Decoded Data: \(scavengerHunt)")
            return scavengerHunt.scavengerHunt
            
        } catch {
            print("Error decoding data: \(error)")
        }
        
        throw "fetchScavengerHuntNearMe error"
    }
    
    func saveScavengerHunt(scavengerHunt: ScavengerHunt) async throws {
        try db.collection("scavengerHunts").document(scavengerHunt.id).setData(from: scavengerHunt)
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
