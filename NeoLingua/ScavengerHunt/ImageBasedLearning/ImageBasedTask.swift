import Foundation

struct ImageBasedTask: Codable {
    let id: String
    let title: String
    let description: String
    let taskPrompt: TaskPrompt
}

//struct UserTaskResult: Codable {
//    let userUid: String
//    let taskId: String
//    let imageUrl: String
//    let title: String
//    let description: String
//    let taskPrompt: TaskPrompt
//    
//    let vocabularyTraining: [VocabularyTask]?
//    let listeningExercise: ListeningExercise?
//}

struct UserTaskPerformance: Codable {
    let userId: String
    let taskId: String
//    var imageUrl: String? = nil
    var vocabularyTraining: TaskPerformancetParameter? = nil
    var listeningComprehension: TaskPerformancetParameter? = nil
    var conversationSimulation: TaskPerformancetParameter? = nil
    
    var didFoundObject: Bool?

    func isTaskDone() -> Bool {
        return vocabularyTraining?.isDone != nil &&
        listeningComprehension?.isDone != nil &&
        conversationSimulation?.isDone != nil
    }
}

struct TaskPerformancetParameter: Codable {
    let isDone: Bool?
    let result: Double
    let time: Double?
    
    init(result: Double = 0, time: Double? = nil, isDone: Bool? = nil) {
        self.result = result
        self.time = time
        self.isDone = isDone
    }
}


enum TaskType: String {
    case vocabularyTraining = "vocabularyTraining"
    case listeningComprehension = "listeningComprehension"
    case conversationSimulation = "conversationSimulation"
}
