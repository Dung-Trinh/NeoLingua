import Foundation

struct TaskLocation: Codable, Identifiable, Equatable {
    let id: String = UUID().uuidString
    let name: String
    let type: String
    let location: Location
    let taskPrompt: TaskPrompt
    let photoClue: String
    let photoObject: String
    var performance: LocationTaskPerformance? = nil
    
    init(
        name: String,
        type: String,
        location: Location,
        taskPrompt: TaskPrompt,
        photoClue: String,
        photoObject: String
    ) {
        self.name = name
        self.type = type
        self.location = location
        self.taskPrompt = taskPrompt
        self.photoClue = photoClue
        self.photoObject = photoObject
    }
    
    static func == (lhs: TaskLocation, rhs: TaskLocation) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.type == rhs.type &&
        lhs.location == rhs.location
    }
}

struct TaskPrompt: Codable {
    let vocabularyTraining: String?
    let listeningComprehension: String?
    let conversationSimulation: String?
}

struct Location: Codable, Hashable{
    let latitude: Double
    let longitude: Double
}
