import Foundation
import FirebaseStorage
import _PhotosUI_SwiftUI
import UIKit
import SwiftOpenAI

protocol ContextAwarePageViewModel: ObservableObject {
    var selectedImage: UIImage? {get set}
    var selectedPhotos: [PhotosPickerItem] {get set}
    
    func convertDataToImage()
    func uploadImage() async
    func setupRouter(_ router: RouterImpl)
    func requestVisionAPI() async
}

class ContextAwarePageViewModelImpl: ContextAwarePageViewModel {
    private var router: RouterImpl?
    private let openAI = SwiftOpenAI(apiKey: ProdENV().OPENAI_KEY)
    private var uploadedImageLink = ""
    
    func setupRouter(_ router: RouterImpl) {
        self.router = router
    }
    
    @Published var selectedImage: UIImage? = nil
    @Published var selectedPhotos = [PhotosPickerItem]()
    
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
    
    func requestVisionAPI() async {
        print("requestVisionAPI")
        
        let message = "What appears in the photo?"
        // let imageVisionURL = "https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/M31bobo.jpg/640px-M31bobo.jpg"
        
        do {
            convertImageURLToBase64DataURL(imageURL: uploadedImageLink) { base64DataURL in
                guard let base64DataURL = base64DataURL else {
                    print("Failed to convert image URL to base64 Data URL")
                    return
                }
                
                let myMessage = MessageChatImageInput(
                    text: message,
                    imageURL: base64DataURL,
                    role: .user
                )
                
                let optionalParameters: ChatCompletionsOptionalParameters = .init(
                    temperature: 0.5,
                    stop: ["stopstring"],
                    stream: false,
                    maxTokens: 1200
                )
                print("requestVisionAPI")
                
                Task {
                    do {
                        let result = try await self.openAI.createChatCompletionsWithImageInput(
                            model: .gpt4o(.base),
                            messages: [myMessage],
                            optionalParameters: optionalParameters
                        )
                        
                        print("Result \(result?.choices.first?.message)")
                        
                        let message = result?.choices.first?.message.content ?? "No value"
                        
                        print(message)
                        
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
        }
        
        func convertImageURLToBase64DataURL(imageURL: String, completion: @escaping (String?) -> Void) {
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
}
