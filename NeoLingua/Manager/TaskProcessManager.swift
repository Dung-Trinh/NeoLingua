import Foundation
import Firebase

class TaskProcessManager {
    static let shared: TaskProcessManager = {
        let instance = TaskProcessManager()
        return instance
    }()
    
    private let db = Firestore.firestore()
    var currentTaskId = ""
    var taskLocationId = ""
    var currentScavengerHunt: ScavengerHunt? = nil

    func saveImageBasedTask(task: ImageBasedTask, imageUrl: String) async throws {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            print("userId not found")
            return
        }
        currentTaskId = task.id
        
        let taskPrompt: [String: Any] = [
            "vocabularyTraining": task.taskPrompt.vocabularyTraining ?? "",
            "listeningComprehension": task.taskPrompt.listeningComprehension ?? "",
            "conversationSimulation": task.taskPrompt.conversationSimulation ?? ""
        ]
        
        let data: [String: Any] = [
            "userId": userId,
            "taskId": task.id,
            "imageUrl": imageUrl,
            "title": task.title,
            "description": task.description,
            "taskPrompt": taskPrompt,
            "vocabularyTraining": [],
            "listeningExercise": nil as AnyObject?
        ]
        try await db.collection("imageBasedTaskResult").addDocument(data: data)
    }
    
    func updateVocabularyExercise(exercises: [VocabularyExercise]) async throws {
        print(currentTaskId)
        
        let querySnapshot = try await db.collection("imageBasedTaskResult")
            .whereField("taskId", isEqualTo: currentTaskId)
            .getDocuments()
        guard let document = querySnapshot.documents.first else {
            print("Kein Task mit der angegebenen taskId gefunden.")
            return
        }
        let documentRef = document.reference
        var vocabularyTraining: [[String:Any]] = []
        for exercise in exercises {
            switch exercise.type {
            case .fillInTheBlanks:
                if let exercise = exercise as? WriteWordExercise {
                    vocabularyTraining.append(exercise.toDictionary())
                }
            case .multipleChoice:
                if let exercise = exercise as? ChooseWordExercise {
                    vocabularyTraining.append(exercise.toDictionary())
                }
            case .sentenceAssembly:
                if let exercise = exercise as? SentenceBuildingExercise{
                    vocabularyTraining.append(exercise.toDictionary())
                }
            }
        }
        
        
        try await documentRef.updateData([
            "vocabularyTraining": vocabularyTraining
        ])
        
        print("vocabularyTraining aktualisiert!")
    }
    
    func createUserResultPerformance(task: ImageBasedTask) async throws {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            print("userUid not found")
            return
        }
        var taskType: [String] = []
        let mirror = Mirror(reflecting: task.taskPrompt)
        
        for child in mirror.children {
            if let label = child.label, child.value as? String != nil {
                taskType.append(label)
            }
        }
        print(taskType.description)
        
        let data: [String: Any] = [
            "userId": userId,
            "taskId": task.id,
            "taskTypes": taskType
        ]
        try await db.collection("imageBasedTaskResult").addDocument(data: data)
    }
    
    func updateTaskPerformance(parameter: TaskPerformancetParameter, taskType: TaskType) async throws {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            print("userId not found")
            return
        }
        
        print("currentTaskId: ", currentTaskId)
        let querySnapshot = try await db.collection("imageBasedTaskResult")
            .whereField("userId", isEqualTo: userId)
            .whereField("taskId", isEqualTo: currentTaskId)
            .getDocuments()
        
        guard let document = querySnapshot.documents.first else {
            print("Kein Task mit der angegebenen taskId gefunden.")
            return
        }
        let documentRef = document.reference
        
        guard let document = querySnapshot.documents.first else {
            print("Kein Task mit der angegebenen taskId gefunden.")
            return
        }
        
        let performance: [String: Any] = [
            "result": parameter.result,
            "time": parameter.time,
            "isDone": parameter.isDone
        ]
        
        try await documentRef.updateData([
            taskType.rawValue: performance
        ])
    }
    
    func updateScavengerHuntState(parameter: TaskPerformancetParameter, taskType: TaskType) async throws {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            print("userId not found")
            return
        }
        print("taskLocationId: ", taskLocationId)
        let snapshot = try await db.collection("scavengerHuntState")
            .whereField("userId", isEqualTo: userId)
            .whereField("scavengerHuntId", isEqualTo: currentScavengerHunt?.id)
            .getDocuments()
        
        guard let document = snapshot.documents.first else {
            print("No scavenger hunt state found.")
            return
        }
        
        var scavengerHuntState = try document.data(as: ScavengerHuntState.self)
        
        for performance in scavengerHuntState.locationTaskPerformance {
            print(performance.locationId == taskLocationId)
            if performance.locationId == taskLocationId {
                for (index, performance) in scavengerHuntState.locationTaskPerformance.enumerated() {
                    if performance.locationId == taskLocationId {
                        switch taskType {
                        case .vocabularyTraining:
                            scavengerHuntState.locationTaskPerformance[index].performance.vocabularyTraining = parameter
                        case .listeningComprehension:
                            scavengerHuntState.locationTaskPerformance[index].performance.listeningComprehension = parameter
                        case .conversationSimulation:
                            scavengerHuntState.locationTaskPerformance[index].performance.conversationSimulation = parameter
                        }
                    }
                }
                
                try document.reference.setData(from: scavengerHuntState)
            }
        }
    }
    
    func fetchUserTaskPerformance() async throws -> UserTaskPerformance? {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            print("userUid not found")
            return nil
        }
        
        let querySnapshot = try await db.collection("imageBasedTaskResult")
            .whereField("userId", isEqualTo: userId)
            .whereField("taskId", isEqualTo: currentTaskId)
            .getDocuments()
        
        guard let document = querySnapshot.documents.first else {
            print("Kein Task mit der angegebenen taskId gefunden.")
            return nil
        }
        
        let task = try document.data(as: UserTaskPerformance.self)
        return task
    }
    
    func fetchTaskLocationState(locationId: String) async throws -> LocationTaskPerformance {
        let scavengerHuntState = try await findScavengerHuntState(scavengerHuntId: currentScavengerHunt?.id ?? "")
        
        for location in scavengerHuntState.locationTaskPerformance {
            if location.locationId == locationId {
                return location
            }
        }
        
        throw "not found LocationTaskPerformance for locationId \(locationId)"
    }
    
    func updateTaskLocationImageState(
        locationId: String,
        result: Bool,
        numberOfAttempts: Int
    ) async throws {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            throw "userId not found"
        }
        let snapshot = try await db.collection("scavengerHuntState")
            .whereField("userId", isEqualTo: userId)
            .whereField("scavengerHuntId", isEqualTo: currentScavengerHunt?.id)
            .getDocuments()
        
        guard let document = snapshot.documents.first else {
            throw "document not found"
        }
        
        var scavengerHuntState = try document.data(as: ScavengerHuntState.self)
        for index in scavengerHuntState.locationTaskPerformance.indices {
            if scavengerHuntState.locationTaskPerformance[index].locationId == locationId {
                scavengerHuntState.locationTaskPerformance[index].performance.didFoundObject = result
                var pointsAsPercentage = 0.0

                if result && numberOfAttempts > 0 {
                    pointsAsPercentage = Double(numberOfAttempts/3).twoDecimals
                    
                    scavengerHuntState.locationTaskPerformance[index].performance.searchingTheObject =  TaskPerformancetParameter(
                        result: pointsAsPercentage,
                        time: 0,
                        isDone: true
                    )
                } else {
                    scavengerHuntState.locationTaskPerformance[index].performance.searchingTheObject =  TaskPerformancetParameter(
                        result: 0,
                        time: 0,
                        isDone: true
                    )
                }
            }
        }
        try document.reference.setData(from: scavengerHuntState)
    }
    
    func findScavengerHuntState(scavengerHuntId: String) async throws -> ScavengerHuntState {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            throw "userId not found"
        }
        let snapshot = try await db.collection("scavengerHuntState")
            .whereField("userId", isEqualTo: userId)
            .whereField("scavengerHuntId", isEqualTo: scavengerHuntId)
            .getDocuments()
        
        guard let document = snapshot.documents.first else {
            throw "document not found"
        }
        
        var scavengerHuntState = try document.data(as: ScavengerHuntState.self)
        return scavengerHuntState
    }
}

extension Double {
    var twoDecimals: Double {
        let stringValue = String(format: "%.2f", self)
        return Double(stringValue) ?? 0.0
    }
}
