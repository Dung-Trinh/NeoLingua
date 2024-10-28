import Foundation
import Alamofire
import SwiftOpenAI
import FirebaseStorage
import _PhotosUI_SwiftUI
import SwiftUI

enum ImageBasedLearningPageState {
    case initialState
    case imageSelected
    case taskAvailable
}

protocol ImageBasedLearningPageViewModel: ObservableObject {

}

class ImageBasedLearningPageViewModelImpl: ImageBasedLearningPageViewModel {
    @Published var selectedPhotos: [PhotosPickerItem] = []
    @Published var selectedImage: UIImage? = nil
    @Published var imageBasedTask: ImageBasedTask?
    @Published var userPerformance: UserTaskPerformance?
    @Published var isSheetPresented: Bool = false
    @Published var state: ImageBasedLearningPageState = .initialState
    @Published var isLoading: Bool = false

    private var uploadedImageLink = ""
    private var taskProcessManager = TaskProcessManager.shared
    private let openAiServiceHelper = OpenAIServiceHelper()
    private let imageProcessingManager = ImageProcessingManager()

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
        state = .imageSelected
        
//        Task {
//            try? await taskProcessManager.saveImageBasedTask(task: TestData.imageBasedTask, imageUrl: "https://firebasestorage.googleapis.com/v0/b/neolingua.appspot.com/o/images%2F9F81734D-46FA-40D0-83B1-E9A8B734DE91.jpg?alt=media&token=07735721-22e5-4688-b681-06a8124dac5a")
//        }
    }
    
    func analyzeImage() async {
        isLoading = true
        defer { isLoading = false }

        do {
            await uploadImage()
            try await createImageBasedTask()
            if let task = imageBasedTask {
                try? await taskProcessManager.createUserResultPerformance(task: task)
            }
            state = .taskAvailable
        } catch {
            print("analyzeImage error: ", error.localizedDescription)
        }
    }
    
    private func uploadImage() async {
        guard let imageData = selectedImage?.jpegData(compressionQuality: 0.8) else { return }
        if let downloadURL = await imageProcessingManager.uploadImageToFirebase(imageData: imageData) {
            uploadedImageLink = downloadURL
        }
    }
    
    private func createImageBasedTask() async throws {
        imageBasedTask = try await imageProcessingManager.createImageBasedTask(imageUrl: uploadedImageLink)
        taskProcessManager.currentTaskId = imageBasedTask?.id ?? ""
    }
    
    func fetchPerformance() async {
        print("fetchPerformance")
        userPerformance =  try? await taskProcessManager.fetchUserTaskPerformance()
        print(userPerformance)
        isSheetPresented = userPerformance?.isTaskDone() ?? false
    }
}
