import Foundation
import Firebase

class TaskProcessManager {
    static let shared: TaskProcessManager = {
        let instance = TaskProcessManager()
        return instance
    }()
    
    let db = Firestore.firestore()
    var currentTaskId = ""
    
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
        try await db.collection("userTaskResult").addDocument(data: data)
    }
    
    func fetchTasksForUser(userId: String) async throws -> [ImageBasedTask] {
        let querySnapshot = try await db.collection("userTaskResult")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        var tasks: [ImageBasedTask] = []
        
        for document in querySnapshot.documents {
            if let task = try? document.data(as: ImageBasedTask.self) {
                tasks.append(task)
            }
        }
        
        return tasks
    }
    
    func updateVocabularyExercise(exercises: [VocabularyExercise]) async throws {
        print(currentTaskId)
        
        let querySnapshot = try await db.collection("userTaskResult")
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
        
        let data: [String: Any] = [
            "userId": userId,
            "taskId": task.id
        ]
        try await db.collection("userTaskResult").addDocument(data: data)
    }
    
    func updateVocabularyPerformance(points: Double, time: Double = 0) async throws {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            print("userId not found")
            return
        }
        
        print("currentTaskId: ", currentTaskId)
        let querySnapshot = try await db.collection("userTaskResult")
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
            "result": points,
            "time": time
        ]
        
        try await documentRef.updateData([
            "vocabularyTraining": performance
        ])
    }
    
    func fetchUserTaskPerformance() async throws -> UserTaskPerformance? {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            print("userUid not found")
            return nil
        }
        
        let querySnapshot = try await db.collection("userTaskResult")
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
}
