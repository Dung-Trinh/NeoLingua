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
    var vocabularyTraining: TaskPerformancetParameter? = nil
    var listeningComprehension: TaskPerformancetParameter? = nil
    var conversationSimulation: TaskPerformancetParameter? = nil
    var searchingTheObject: TaskPerformancetParameter? = nil

    var taskTypes: [TaskType] = []
    var didFoundObject: Bool?

    func isTaskDone() -> Bool {
        var isTaskDone = true
        
        for type in taskTypes {
            if type == .vocabularyTraining && vocabularyTraining?.isDone == nil {
                isTaskDone = false
            } else if type == .listeningComprehension && listeningComprehension?.isDone == nil {
                isTaskDone = false
            } else if type == .conversationSimulation && conversationSimulation?.isDone == nil {
                isTaskDone = false
            }
        }
        
        return isTaskDone
    }
}

struct TaskPerformancetParameter: Codable {
    let isDone: Bool?
    let result: Double
    let time: Double?
    var amountOfErrors: Double?
    
    var resultPercentage: String {
        String(result * 100)
    }
    
    init(result: Double = 0, time: Double? = nil, isDone: Bool? = nil) {
        self.result = result.twoDecimals
        self.time = time
        self.isDone = isDone
    }
    
    func getPoint(maxPoints: Double) -> Double {
        return Double((result * 100) * maxPoints / 100).twoDecimals
    }
    
    func getPointString(maxPoints: Double) -> String {
        return String(Double((result * 100) * maxPoints / 100).twoDecimals) + "/" +  String(maxPoints)
    }
}


enum TaskType: String, CaseIterable, Codable {
    case vocabularyTraining = "vocabularyTraining"
    case listeningComprehension = "listeningComprehension"
    case conversationSimulation = "conversationSimulation"
    
    var localizedText: String {
            switch self {
            case .vocabularyTraining:
                return "Vokabelübung"
            case .listeningComprehension:
                return "Hörverständnis"
            case .conversationSimulation:
                return "Gesprächssimulation"
            }
        }
}
