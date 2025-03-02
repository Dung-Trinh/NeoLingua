import Foundation
import SwiftUI
import SwiftOpenAI
import FirebaseStorage
import Alamofire
import Firebase

struct ThreadResponse: Decodable {
    let id: String
    let object: String
    let createdAt: TimeInterval
    let metadata: [String: String]?
    let toolResources: [String: String]?

    private enum CodingKeys: String, CodingKey {
        case id
        case object
        case createdAt = "created_at"
        case metadata
        case toolResources = "tool_resources"
    }
}

class ImageProcessingManager {
    private let apiKey = ProdENV().OPENAI_KEY
    private let openAiServiceHelper = OpenAIManager()
    private let imageBasedAssistantID = ProdENV().CONTEXT_BASED_LEARNING_ASSISTANT_ID
    private let db = Firestore.firestore()

    var currentThreadID = ""
    
    func createImageBasedTask(
        imageUrl: String,
        excludedTaskTypes: [TaskType],
        imageLocation: Location? = nil
    ) async throws -> ImageBasedTask? {
        if CommandLine.arguments.contains("--useMockData") {
            return TestData.imageBasedTask
        }
        let languageLevel = UserDefaults().getLevelOfLanguage().rawValue
        var excludedTasks = ""
        if excludedTaskTypes != [] {
            var typesArray: [String] = []
            for taskType in excludedTaskTypes {
                typesArray.append(taskType.rawValue.description)
            }
            excludedTasks = "exclude \(typesArray.split(separator: ","))"
        }
        
        var imageLocationText = ""
        if let imageLocation = imageLocation {
            imageLocationText = "the image has this metadata latitude: \(imageLocation.latitude) and longitude: \(imageLocation.longitude)."
        }
            
        let newThread = try await createThreadWithImage(
            imageUrl: imageUrl,
            prompt: "what can be seen in the picture? create task prompts for it with the language level \(languageLevel).\(imageLocationText) \(excludedTasks)"
        )
        let jsonStringResponse = try await openAiServiceHelper.getJsonResponseAfterRun(
            assistantID: imageBasedAssistantID,
            threadID: newThread.id
        )
        
        print("jsonStringResponse")
        print(jsonStringResponse)
        
        if let jsonData = jsonStringResponse.data(using: .utf8) {
            let decodedData = try JSONDecoder().decode(ImageBasedTask.self, from: jsonData)
            return decodedData
        }
        
        return nil
    }
        
    func verifyImage(imageUrl: String, searchedObject: String) async throws -> ImageValidationResult? {
        let imageAnalyser = ProdENV().IMAGE_ANALYZER_ASSISTANT_ID
        
        if CommandLine.arguments.contains("--useMockData") {            
            return TestData.imageValidationResult
        }
        
        let prompt = "ValidateDescriptionWithImage: is this object on the following image: \(searchedObject)"
        let newThread = try await createThreadWithImage(imageUrl: imageUrl, prompt: prompt)
        let jsonStringResponse = try await openAiServiceHelper.getJsonResponseAfterRun(
            assistantID: imageAnalyser,
            threadID: newThread.id
        )
        
        currentThreadID = newThread.id
        print("jsonStringResponse")
        print(jsonStringResponse)
        if let jsonData = jsonStringResponse.data(using: .utf8) {
            let decodedData = try JSONDecoder().decode(ImageValidationResult.self, from: jsonData)
            return decodedData
        }
        throw "verifyImage error"
    }
    
    func verifyTextWithImage(
        imageUrl: String,
        searchedVocabulary: [String],
        userInput: String
    ) async throws -> InspectImageForVocabularyResult {
        if currentThreadID == "" {
            let newThread = try await createThreadWithImage(
                imageUrl: imageUrl,
                prompt: "InspectImageForVocabulary; searchedVocabulary: \(searchedVocabulary.joined(separator: ",")); userInput: \(userInput)"
            )
            currentThreadID = newThread.id
        } else {
            try await openAiServiceHelper.sendUserMessageToThread(message: "InspectImageForVocabulary; searchedVocabulary: \(searchedVocabulary.joined(separator: ",")); userInput: \(userInput)", threadID: currentThreadID)
        }
        
        let jsonStringResponse = try await openAiServiceHelper.getJsonResponseAfterRun(
            assistantID: ProdENV().IMAGE_ANALYZER_ASSISTANT_ID,
            threadID: currentThreadID
        )
        
        print("jsonStringResponse")
        print(jsonStringResponse)
        
        if let jsonData = jsonStringResponse.data(using: .utf8) {
            let decodedData = try JSONDecoder().decode(InspectImageForVocabularyResult.self, from: jsonData)
            return decodedData
        }
        throw "verifyTextWithImage error"
    }
    
    func validateVocabularyInImage(imageUrl: String, vocabulary: [String]) async throws -> [VerifiedVocabular] {
        if currentThreadID == "" {
            let newThread = try await createThreadWithImage(
                imageUrl: imageUrl,
                prompt: "ValidateVocabularyInImage; vocabulary: \(vocabulary.joined(separator: ", "))"
            )
            currentThreadID = newThread.id
        } else {
            try await openAiServiceHelper.sendUserMessageToThread(message: "ValidateVocabularyInImage; vocabulary: \(vocabulary.joined(separator: ","));", threadID: currentThreadID)
        }
        
        let jsonStringResponse = try await openAiServiceHelper.getJsonResponseAfterRun(
            assistantID: ProdENV().IMAGE_ANALYZER_ASSISTANT_ID,
            threadID: currentThreadID
        )
        
        print("jsonStringResponse")
        print(jsonStringResponse)
        
        if let jsonData = jsonStringResponse.data(using: .utf8) {
            let decodedData = try JSONDecoder().decode(ValidateVocabularyInImageResult.self, from: jsonData)
            return decodedData.vocabulary
        }
        throw "validateVocabularyInImage error"
    }
    
    func saveSnapVocabularyTask(sharedContentForTask: SharedContentForTask, vocabulary: [String]) throws {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            print("userId not found")
            return
        }
        let task = SnapVocabularyTask(
            id: UUID().uuidString,
            userId: userId,
            coordinates: sharedContentForTask.coordinates ?? Location(latitude: 0, longitude: 0),
            imageUrl: sharedContentForTask.uploadedLink,
            vocabulary: vocabulary
        )
        try db.collection("imageBasedTasks").addDocument(from: task)
    }
    
    func fetchImageHint() async throws -> String {
        try await openAiServiceHelper.sendUserMessageToThread(message: "I need a hint", threadID: currentThreadID)
        let jsonStringResponse = try await openAiServiceHelper.getJsonResponseAfterRun(
            assistantID: ProdENV().IMAGE_ANALYZER_ASSISTANT_ID,
            threadID: currentThreadID
        )
        
        print("jsonStringResponse")
        print(jsonStringResponse)
        if let jsonData = jsonStringResponse.data(using: .utf8) {
            let decodedData = try JSONDecoder().decode(InspectImageForVocabularyHint.self, from: jsonData)
            return decodedData.hint
        }
        throw "fetchImageHint error"
    }
    
    func createTasksWithContextPrompt(
        prompt: String,
        excludedTaskTypes: [TaskType]
    ) async throws -> ImageBasedTask? {
        if CommandLine.arguments.contains("--useMockData") {
            return TestData.imageBasedTask
        }
        let languageLevel = UserDefaults().getLevelOfLanguage().rawValue
        var excludedTasks = ""
        if excludedTaskTypes != [] {
            var typesArray: [String] = []
            
            for taskType in excludedTaskTypes {
                typesArray.append(taskType.rawValue.description)
            }
            
            excludedTasks = "exclude \(typesArray.split(separator: ","))"
        }
            
        let newThread = try await openAiServiceHelper.service.createThread(parameters: CreateThreadParameters())
        currentThreadID = newThread.id
        
        try await openAiServiceHelper.sendUserMessageToThread(
            message: "\(prompt) . create task prompts for it with the language level \(languageLevel).\(excludedTasks)",
            threadID: currentThreadID
        )

        let jsonStringResponse = try await openAiServiceHelper.getJsonResponseAfterRun(
            assistantID: imageBasedAssistantID,
            threadID: currentThreadID
        )
        
        print("jsonStringResponse")
        print(jsonStringResponse)
        
        if let jsonData = jsonStringResponse.data(using: .utf8) {
            let decodedData = try JSONDecoder().decode(ImageBasedTask.self, from: jsonData)
            return decodedData
        }
        
        return nil
    }
    
    private func createThreadWithImage(imageUrl: String, prompt: String) async throws -> ThreadResponse {
        let url = "https://api.openai.com/v1/threads"
        let apiKey = ProdENV().OPENAI_KEY
        let parameters: [String: Any] = [
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "\(prompt)"
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "\(imageUrl)",
                                "detail": "auto"
                            ]
                        ]
                    ]
                ]
            ]
        ]
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json",
            "OpenAI-Beta": "assistants=v2"
        ]

        return try await withCheckedThrowingContinuation { continuation in
            AF.request(
                url,
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: headers
            ).responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let threadResponse = try JSONDecoder().decode(ThreadResponse.self, from: data)
                        print("thread with image ID: ", threadResponse.id)
                        continuation.resume(returning: threadResponse)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
