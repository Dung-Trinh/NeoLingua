import Foundation
import SwiftOpenAI

class TaskManager {
    let service = OpenAIServiceProvider.shared
    let openAiServiceHelper = OpenAIManager()
    let decoder = JSONDecoder()
    var threadID = ""
}

protocol ListeningComprehensionManager {
    func fetchListeningComprehensionTask(prompt: String) async throws -> ListeningExercise?
    func createSpeech(text: String) async throws -> Data
    func fetchListeningTaskEvaluation(userAnswer: String) async throws -> ListeningTaskEvaluation?
}

class ListeningComprehensionManagerImpl: TaskManager, ListeningComprehensionManager {
    private let assistantID = ProdENV().LISTENING_COMPREHENSION_ASSISTANT_ID

    func fetchListeningComprehensionTask(prompt: String) async throws -> ListeningExercise? {
        if CommandLine.arguments.contains("--useMockData") {
            return TestData.listeningExercise
        }
        
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
        if CommandLine.arguments.contains("--useMockData") {
            return TestData.listeningExerciseEvaluation
        }
        
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
            speed: 1
        )
        let speech = try await service.createSpeech(parameters: parameters).output
        return speech
    }
}
