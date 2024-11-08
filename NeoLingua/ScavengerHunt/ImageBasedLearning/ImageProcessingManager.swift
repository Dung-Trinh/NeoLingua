import Foundation
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
    private let openAiServiceHelper = OpenAIServiceHelper()
    private let imageBasedAssistantID = ProdENV().CONTEXT_BASED_LEARNING_ASSISTANT_ID
    private let db = Firestore.firestore()

    var currentThreadID = ""
    func createImageBasedTask(imageUrl: String, excludedTaskTypes: [TaskType]) async throws -> ImageBasedTask? {
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
            
        let newThread = try await createThreadWithImage(
            imageUrl: imageUrl,
            prompt: "what can be seen in the picture? create task prompts for it with the language level \(languageLevel). \(excludedTasks)"
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
    
    func uploadImageToFirebase(imageData: Data) async -> String? {
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("images/\(UUID().uuidString).jpg")
        let metadata = try? await imageRef.putDataAsync(imageData)
        let downloadURL = try? await imageRef.downloadURL()
        print(downloadURL?.absoluteString)

        return downloadURL?.absoluteString
    }
    
    func verifyImage(imageUrl: String, searchedObject: String) async throws -> ImageValidationResult? {
        let imageAnalyser = "asst_UGMnDx0fcYMJNFhEhu6PVDrr"
        
        if CommandLine.arguments.contains("--useMockData") {            
            return TestData.imageValidationResult
        }
        
        let prompt = "is this object on the following image: \(searchedObject)"
        let newThread = try await createThreadWithImage(imageUrl: imageUrl, prompt: searchedObject)
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

struct ImageValidationResult: Codable {
    let isMatching: Bool
    let reason: String
    let confidenceScore: Double
}

struct InspectImageForVocabularyResult: Codable {
    let foundSearchedVocabulary: Bool
    let result: EvaluationStatus
    let correctedText: String?
}

enum EvaluationStatus: String, Codable {
    case correct
    case wrong
    case almostCorrect
}

struct InspectImageForVocabularyHint: Codable {
    let hint: String
}

struct ValidateVocabularyInImageResult: Codable {
    let vocabulary: [VerifiedVocabular]
}

struct VerifiedVocabular: Codable, Identifiable {
    var id: String
    let name: String
    let isInImage: Bool
    let improvement: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.isInImage = try container.decode(Bool.self, forKey: .isInImage)
        self.improvement = try container.decodeIfPresent(String.self, forKey: .improvement)
        self.id = UUID().uuidString
    }
    
    init(name: String, isInImage: Bool, improvement: String?) {
        self.name = name
        self.isInImage = isInImage
        self.improvement = improvement
        self.id = UUID().uuidString
    }
}
