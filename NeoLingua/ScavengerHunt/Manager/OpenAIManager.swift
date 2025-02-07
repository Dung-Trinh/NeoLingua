import Foundation
import SwiftOpenAI

class OpenAIServiceProvider {
    static let shared: OpenAIService = {
        let instance = OpenAIServiceFactory.service(apiKey: ProdENV().OPENAI_KEY)
        return instance
    }()
}

class OpenAIManager {
    let service = OpenAIServiceProvider.shared
    
    func getJsonResponseAfterRun(
        assistantID: String,
        threadID: String
    ) async throws -> String {
        let runParameter = RunParameter(assistantID: assistantID)
        let stream = try await service.createRunStream(threadID: threadID, parameters: runParameter)
        
        var jsonStringResponse = ""
        for try await result in stream {
            switch result {
            case .threadMessageDelta(let messageDelta):
                let content = messageDelta.delta.content.first
                switch content {
                case .imageFile, nil:
                    break
                case .text(let textContent):
                    jsonStringResponse += textContent.text.value
                }
            default: break
            }
        }
        return jsonStringResponse
    }
    
    func sendUserMessageToThread(
        message: String,
        threadID: String
    ) async throws {
        let parameters = MessageParameter(
            role: .user,
            content: message
        )
        let _ = try await service.createMessage(
            threadID: threadID,
            parameters: parameters
        )
    }
}
