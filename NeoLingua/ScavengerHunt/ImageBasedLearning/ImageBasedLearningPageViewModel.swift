import Foundation
import SwiftOpenAI
import FirebaseStorage
import _PhotosUI_SwiftUI

protocol ImageBasedLearningPageViewModel: ObservableObject {

}

class ImageBasedLearningPageViewModelImpl: ImageBasedLearningPageViewModel {
    @Published var selectedPhotos = [PhotosPickerItem]()
    @Published var selectedImage: UIImage? = nil
    private var uploadedImageLink = ""
    
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
    }
    
    func requestVisionAPI3() async throws {
        let service = OpenAIServiceProvider.shared
        let openAiServiceHelper = OpenAIServiceHelper()
        var threadID = ""
        let assistantID = ProdENV().CONTEXT_BASED_LEARNING_ASSISTANT_ID

        await uploadImage()
        let prompt = ""
        
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
        
        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }
            print("Image uploaded successfully path: \(metadata?.path ?? "")")
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    return
                }
                if let downloadURL = url {
                    print("Image uploaded successfully. Download URL: \(downloadURL.absoluteString)")
                    self.uploadedImageLink = downloadURL.absoluteString
                }
            }
        }
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
}
