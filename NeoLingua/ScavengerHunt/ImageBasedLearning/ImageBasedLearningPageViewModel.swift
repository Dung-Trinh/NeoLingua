import Foundation
import SwiftOpenAI
import FirebaseStorage
import _PhotosUI_SwiftUI
import SwiftUI

protocol ImageBasedLearningPageViewModel: ObservableObject {

}

class ImageBasedLearningPageViewModelImpl: ImageBasedLearningPageViewModel {
    @Published var selectedPhotos = [PhotosPickerItem]()
    @Published var selectedImage: UIImage? = nil
    @Published var imageBasedTask: ImageBasedTask?
    @Published var userPerformance: UserTaskPerformance?
    @Published var isSheetPresented: Bool = false

    private var uploadedImageLink = ""
    private var taskProcessManager = TaskProcessManager.shared

    @State private var selectedImageURLS: [URL] = []
    @State private var selectedImages: [Image] = []
    let service = OpenAIServiceProvider.shared

    @MainActor
    func convertDataToImage() {
        selectedImage = nil
        
        if !selectedPhotos.isEmpty {
            for eachItem in selectedPhotos {
                Task {
                    if let imageData = try? await eachItem.loadTransferable(type: Data.self) {
                        if let image = UIImage(data: imageData) {
                            self.selectedImage = image
                        }
                    }
                }
            }
        }
        selectedPhotos.removeAll()
        
        // MOCKDATA
        imageBasedTask = TestData.imageBasedTask
        taskProcessManager.currentTaskId = imageBasedTask?.id ?? ""
//        Task {
//            try? await taskProcessManager.saveImageBasedTask(task: TestData.imageBasedTask, imageUrl: "https://firebasestorage.googleapis.com/v0/b/neolingua.appspot.com/o/images%2F9F81734D-46FA-40D0-83B1-E9A8B734DE91.jpg?alt=media&token=07735721-22e5-4688-b681-06a8124dac5a")
//        }
    }
    
    func requestVisionAPI3() async throws {
        let service = OpenAIServiceProvider.shared
        let openAiServiceHelper = OpenAIServiceHelper()
        var threadID = ""
        let assistantID = ProdENV().CONTEXT_BASED_LEARNING_ASSISTANT_ID

        await uploadImage()
        let prompt = "was ist auf dem bild"
        
        print("uploadedImageLink")
        print(uploadedImageLink)

        guard let imageURL = URL(string: "https://assets.ad-magazin.de/photos/6557824498b1772247ba4c33/16:9/w_2560%2Cc_limit/GettyImages-1730743172.jpg"),
              let imageData = try? Data(contentsOf: imageURL) else {
            print("Fehler beim Herunterladen des Bildes")
            return
        }
        
//        let prompt = "a planet with some stars"
//        
//        guard let imageURL = URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/M31bobo.jpg/640px-M31bobo.jpg"),
//              let imageData = try? Data(contentsOf: imageURL) else {
//            print("Fehler beim Herunterladen des Bildes")
//            return
//        }
        
        let imageContent = """
        {
          "type": "image_url",
          "image_url": {
            "url": "\(imageURL)"
          }
        }
        """

        let textContent = """
        {
          "type": "text",
          "text": "\(prompt)"
        }
        """

        let content = "[\(textContent), \(imageContent)]"

        let parameters = MessageParameter(
            role: .user,
            content: content
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
        print("jsonStringResponse")
        print(jsonStringResponse)
    }
    
    func uploadImage() async {
        guard let imageData = selectedImage?.jpegData(compressionQuality: 0.8) else { return }
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("images/\(UUID().uuidString).jpg")
        
        let metadata = try? await imageRef.putDataAsync(imageData)
        let downloadURL = try? await imageRef.downloadURL()
        print(downloadURL?.absoluteString)
        Task {
//            try? await taskProcessManager.saveImageBasedTask(task: TestData.imageBasedTask, imageUrl: downloadURL?.absoluteString ?? "")
            if let task = imageBasedTask {
                try? await taskProcessManager.createUserResultPerformance(task: task)
            }
            
        }
        
//        imageRef.putData(imageData, metadata: nil) { metadata, error in
//            if let error = error {
//                print("Error uploading image: \(error.localizedDescription)")
//                return
//            }
//            print("Image uploaded successfully path: \(metadata?.path ?? "")")
//            imageRef.downloadURL { url, error in
//                if let error = error {
//                    print("Error getting download URL: \(error.localizedDescription)")
//                    return
//                }
//                if let downloadURL = url {
//                    print("Image uploaded successfully. Download URL: \(downloadURL.absoluteString)")
//                    self.uploadedImageLink = downloadURL.absoluteString
//                }
//            }
//        }
    }
    
    private func convertImageURLToBase64DataURL(imageURL: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: imageURL) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error downloading image: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            // convert data to base64 string
            let base64String = data.base64EncodedString()
            let dataURLString = "data:image/jpeg;base64,\(base64String)"
            completion(dataURLString)
        }
        
        task.resume()
    }
    
    // bild wird erkannt aber kann nicht genauso an einem bestimmten assistenten geschickt werden TODO: antwort in json transformieren
    func sendRequest() async {
        // Make the request
        let urlMain: URL? = URL(string: "https://assets.ad-magazin.de/photos/6557824498b1772247ba4c33/16:9/w_2560%2Cc_limit/GettyImages-1730743172.jpg")
        
        print("sendRequest")
        print(selectedImageURLS)
        let prompt = "was sieht man uaf dem bild"
        let content: [ChatCompletionParameters.Message.ContentType.MessageContent] = [
            .text(prompt)
            
        ] + [.imageUrl(.init(url: urlMain!))]
        print(content)
        
        do {
            let result = try await service.startStreamedChat(parameters: .init(
                messages: [.init(role: .user, content: .contentArray(content))],
                model: .gpt4o, maxTokens: 300))
            var completeResponse = ""

            for try await partialResponse in result {
                completeResponse += partialResponse.choices.first?.delta.content ?? ""            }
            print("Vollständige Antwort: \(completeResponse)")

        } catch {
            print("sendRequest error: :", error.localizedDescription)
        }
    }
    
    func fetchPerformance() async {
        print("fetchPerformance")
        userPerformance =  try? await taskProcessManager.fetchUserTaskPerformance()
        print(userPerformance)
        isSheetPresented = userPerformance?.isTaskDone() ?? false
    }
}
