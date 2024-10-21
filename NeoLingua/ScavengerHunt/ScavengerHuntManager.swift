import Foundation
import SwiftOpenAI

struct TaskPrompt: Codable {
    let vocabularyTraining: String
    let listeningComprehension: String
    let conversationSimulation: String
}

struct Location: Codable {
    let latitude: Double
    let longitude: Double
}

struct TaskLocation: Codable {
    let name: String
    let type: String
    let location: Location
    let taskPrompt: TaskPrompt
    let photoClue: String
    let photoObject: String
}

struct ScavengerHunt: Codable {
    let id: String
    let introduction: String
    let taskLocations: [TaskLocation]
}

class ScavengerHuntManager: TaskManager {
    let assistantID = ProdENV().TASK_ASSISTANT_ID

    func fetchScavengerHunt() async throws -> ScavengerHunt? {
        let prompt = "kurhaus and kurpark in wiesbaden"
        let parameters = MessageParameter(
            role: .user,
            content: prompt
        )
        
        let thread = try await service.createThread(parameters: CreateThreadParameters())
        threadID = thread.id
        let _ = try await service.createMessage(
            threadID: threadID,
            parameters: parameters
        )
        
        let jsonString = try await openAiServiceHelper.getJsonResponseAfterRun(
            assistantID: assistantID,
            threadID: threadID
        )
        
        print("fetchScavengerHunt:")
        print(jsonString)
        
        if let jsonData = jsonString.data(using: .utf8) {
            let scavengerHunt = try decoder.decode(ScavengerHunt.self, from: jsonData)
            return scavengerHunt
        }
        return nil
    }
}
