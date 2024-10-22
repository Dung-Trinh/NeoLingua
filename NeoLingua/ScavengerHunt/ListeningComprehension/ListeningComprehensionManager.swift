import Foundation
import SwiftOpenAI

class TaskManager {
    let service = OpenAIServiceProvider.shared
    let openAiServiceHelper = OpenAIServiceHelper()
    let decoder = JSONDecoder()
    var threadID = ""
}

class ListeningComprehensionManager: TaskManager {
    let assistantID = ProdENV().LISTENING_COMPREHENSION_ASSISTANT_ID

    func fetchListeningComprehensionTask(prompt: String) async throws -> ListeningExercise? {
//        let prompt = "create a listening comprehension task with the topic 'warmer damm' in Wiesbaden"
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
        
        let jsonStringResponse = try await openAiServiceHelper.getJsonResponseAfterRun(
            assistantID: assistantID,
            threadID: threadID
        )
        print("fetchListeningComprehensionTask:")
        print(jsonStringResponse)
        
        if let jsonData = jsonStringResponse.data(using: .utf8) {
            let exercise = try decoder.decode(ListeningExercise.self, from: jsonData)
            return exercise
        }
        return nil
    }
    
    func fetchListeningTaskEvaluation(userAnswer: String) async throws -> ListeningTaskEvaluation? {
        try await openAiServiceHelper.sendUserMessageToThread(
            message: userAnswer,
            threadID: threadID
        )
        
        let jsonString = try await openAiServiceHelper.getJsonResponseAfterRun(
            assistantID: assistantID,
            threadID: threadID
        )
        print("fetchListeningTaskEvaluation:")
        print(jsonString)
        
        if let jsonData = jsonString.data(using: .utf8) {
            let exercise = try decoder.decode(ListeningTaskEvaluation.self, from: jsonData)
            return exercise
        }
        return nil
    }
    
    func createSpeech(text: String) async throws -> Data {
        let parameters = AudioSpeechParameters(
            model: .tts1,
            input: text,
            voice: .shimmer,
            speed: 0.8
        )
        let speech = try await service.createSpeech(parameters: parameters).output
        return speech
    }
}
