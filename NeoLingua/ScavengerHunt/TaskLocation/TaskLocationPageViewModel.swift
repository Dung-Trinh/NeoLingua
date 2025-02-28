import Foundation
import _PhotosUI_SwiftUI

protocol TaskLocationPageViewModel: ObservableObject {
    var taskLocation: TaskLocation { get }
    var selectedPhotos: [PhotosPickerItem] { get set }
    var selectedImage: UIImage? { get set}
    var showCamera: Bool { get set }
    var isLoading: Bool { get }
    var isSheetPresented: Bool { get set }
    var imageValidationResult: ImageValidationResult? { get }
    var numberOfAttempts: Int { get }
    
    func fetchTaskLocationState() async
    func convertDataToImage()
    func verifyImage() async
}

class TaskLocationPageViewModelImpl: TaskLocationPageViewModel {
    private var uploadedImageLink = ""
    private let imageProcessingManager = ImageProcessingManager()
    private let taskProcessManager = TaskProcessManager.shared
    private let firebaseDataManager = FirebaseDataManagerImpl()
    
    @Published var taskLocation: TaskLocation
    @Published var selectedPhotos: [PhotosPickerItem] = []
    @Published var selectedImage: UIImage? = nil
    @Published var showCamera = false
    @Published var isLoading: Bool = false
    @Published var isSheetPresented: Bool = false
    @Published var imageValidationResult: ImageValidationResult?
    @Published var numberOfAttempts = 3

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
            try await taskProcessManager.updateTaskLocationImageState(
                locationId: taskLocation.id,
                result: imageValidationResult?.isMatching ?? false,
                numberOfAttempts: numberOfAttempts
            )
            if imageValidationResult?.isMatching == false {
                numberOfAttempts -= 1
            }
            
            isSheetPresented = true
            print("imageValidationResult")
            print(imageValidationResult)
        } catch {
            print("verifyImage error: ", error.localizedDescription)
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
        if let downloadURL = await firebaseDataManager.uploadImageToFileStorage(imageData: imageData) {
            uploadedImageLink = downloadURL
        }
    }
}
