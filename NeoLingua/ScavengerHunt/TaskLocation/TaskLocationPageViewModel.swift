import Foundation
import _PhotosUI_SwiftUI

protocol TaskLocationPageViewModel: ObservableObject {
    
}

class TaskLocationPageViewModelImpl: TaskLocationPageViewModel {
    @Published var taskLocation: TaskLocation
    @Published var selectedPhotos: [PhotosPickerItem] = []
    @Published var selectedImage: UIImage? = nil
    @Published var showCamera = false
    @Published var isLoading: Bool = false
    @Published var isSheetPresented: Bool = false
    @Published var imageValidationResult: ImageValidationResult?
    
    private var uploadedImageLink = ""
    private let imageProcessingManager = ImageProcessingManager()
    private let taskProcessManager = TaskProcessManager.shared

    init(taskLocation: TaskLocation) {
        self.taskLocation = taskLocation
        taskProcessManager.taskLocationId = taskLocation.id
    }
    
    func fetchTaskLocationState() async {
        do {
            let locationTaskPerformance = try await taskProcessManager.fetchTaskLocationState(locationId: taskLocation.id)
            taskLocation.performance = locationTaskPerformance
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func verifyImage() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            await uploadImage()
            imageValidationResult = try await imageProcessingManager.verifyImage(
                imageUrl: uploadedImageLink,
                searchedObject: taskLocation.photoObject
            )
            try await taskProcessManager.updateTaskLocationImageState(locationId: taskLocation.id, result: imageValidationResult?.isMatching ?? false)
            isSheetPresented = true
            print("imageValidationResult")
            print(imageValidationResult)
        } catch {
            print("verifyImage error")
        }
    }
    
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
    
    private func uploadImage() async {
        guard let imageData = selectedImage?.jpegData(compressionQuality: 0.8) else { return }
        if let downloadURL = await imageProcessingManager.uploadImageToFirebase(imageData: imageData) {
            uploadedImageLink = downloadURL
        }
    }
}
