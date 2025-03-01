import SwiftOpenAI
import Foundation

protocol ConversationSimulationManager {
    func selectedRole(selectedRole: RoleOption) async throws -> IntroResponse?
    func createConversation(prompt: String) async throws -> RoleOptionsResponse?
    func sendMessageAndGetResponse(message: String) async throws -> ConversationResponse?
    func fetchEvaluation() async throws -> ConversationEvaluation?
}

class ConversationSimulationManagerImpl: ConversationSimulationManager {
    let service = OpenAIServiceProvider.shared
    let assistantID = ProdENV().CONVERSATION_ASSISTANT_ID
    var threadID = ""

    func selectedRole(selectedRole: RoleOption) async throws -> IntroResponse? {
        if CommandLine.arguments.contains("--useMockData") {
            return TestData.conversationIntroResponse
        }
        
        let prompt = "userSelection: \(selectedRole.role)"
        await sendUserMessageToCurrentThread(message: prompt)
        
        let resultJsonString = try await getJsonResponseAfterRun()
        if let jsonData = resultJsonString.data(using: .utf8) {
            let introResponse = try JSONDecoder().decode(IntroResponse.self, from: jsonData)
            
            print("introResponse: \(introResponse.introText)")
            return introResponse
        }
        return nil
    }
    
    func createConversation(prompt: String) async throws -> RoleOptionsResponse? {
        if CommandLine.arguments.contains("--useMockData") {
            return TestData.roleOptionsResponse
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
        
        let jsonStringResponse = try await getJsonResponseAfterRun()
        print("createConversationResponse Text:")
        print(jsonStringResponse)
        
        if let jsonData = jsonStringResponse.data(using: .utf8) {
            let decodedData = try JSONDecoder().decode(RoleOptionsResponse.self, from: jsonData)
            return decodedData
        }
        
        return nil
    }
    
    func sendMessageAndGetResponse(message: String) async throws -> ConversationResponse? {
        if CommandLine.arguments.contains("--useMockData") {
            return TestData.conversationResponse
        }
        
        await sendUserMessageToCurrentThread(message: message)
        let resultJsonString = try await getJsonResponseAfterRun()
        if let jsonData = resultJsonString.data(using: .utf8) {
            let conversationResponse = try JSONDecoder().decode(ConversationResponse.self, from: jsonData)
            return conversationResponse
        }
        return nil
    }
    
    func fetchEvaluation() async throws -> ConversationEvaluation? {
        if CommandLine.arguments.contains("--useMockData") {
            return TestData.conversationEvaluation
        }
        
        await sendUserMessageToCurrentThread(message: "give me an evaluation of the conversation")
        let resultJsonString = try await getJsonResponseAfterRun()
        if let jsonData = resultJsonString.data(using: .utf8) {
            let conversationEvaluation = try JSONDecoder().decode(ConversationEvaluation.self, from: jsonData)
            print("ConversationEvaluation: \(conversationEvaluation)")
            return conversationEvaluation
        }
        return nil
    }
    
    private func getJsonResponseAfterRun() async throws -> String {
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
    
    private func sendUserMessageToCurrentThread(message: String) async {
        let parameters = MessageParameter(
            role: .user,
            content: message
        )
        do {
            let _ = try await service.createMessage(
                threadID: threadID,
                parameters: parameters
            )
        } catch {
            print("createMessage error: ", error.localizedDescription)
        }
    }
}
