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
    let listeningExercise: TaskPerformancetParameter?
    let conversationSimulation: TaskPerformancetParameter?
}

struct TaskPerformancetParameter: Codable {
    let result: Double
    let time: Double?
}
