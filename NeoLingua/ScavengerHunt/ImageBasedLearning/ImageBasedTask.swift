import Foundation

struct ImageBasedTask: Codable {
    let id: String
    let title: String
    let description: String
    let taskPrompt: TaskPrompt
}

struct UserTaskResult: Codable {
    let userUid: String
    let taskId: String
    let imageUrl: String
    let title: String
    let description: String
    let taskPrompt: TaskPrompt
    
    let vocabularyTraining: [VocabularyTask]?
    let listeningExercise: ListeningExercise?
}

struct UserTaskPerformance: Codable {
    let userId: String
    let taskId: String
    let imageUrl: String?
    let vocabularyTraining: TaskPerformancetParameter?
    let listeningComprehension: TaskPerformancetParameter?
    let conversationSimulation: TaskPerformancetParameter?
    
    func isTaskDone() -> Bool {
        return vocabularyTraining != nil &&
        listeningComprehension != nil &&
        conversationSimulation != nil
    }
}

struct TaskPerformancetParameter: Codable {
    let result: Double
    let time: Double?
    
    init(result: Double, time: Double? = nil) {
        self.result = result
        self.time = time
    }
}


enum TaskType: String {
    case vocabularyTraining = "vocabularyTraining"
    case listeningComprehension = "listeningComprehension"
    case conversationSimulation = "conversationSimulation"
}
