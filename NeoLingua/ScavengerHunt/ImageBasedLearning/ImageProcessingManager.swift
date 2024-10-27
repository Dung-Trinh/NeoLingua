import Foundation
import FirebaseStorage
import Alamofire

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
    
    func createImageBasedTask(imageUrl: String) async throws -> ImageBasedTask? {
        let newThread = try await createThreadWithImage(imageUrl: imageUrl)
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
    
    private func createThreadWithImage(imageUrl: String) async throws -> ThreadResponse {
        let url = "https://api.openai.com/v1/threads"
        let apiKey = ProdENV().OPENAI_KEY
        let parameters: [String: Any] = [
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "what can be seen in the picture?"
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
