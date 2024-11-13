import Foundation
import Alamofire
import SwiftOpenAI
import FirebaseStorage
import _PhotosUI_SwiftUI
import SwiftUI

struct SharedContentForTask: Hashable {
    let image: UIImage
    let uploadedLink: String
    let coordinates: Location?
}

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
    @Published var areAllTaskDone: Bool = false
    @Published var showCamera = false
    @Published var excludedTaskType: [TaskType] = []
    @Published var promptText: String = ""

    private var imageCoordinates: Location?
    var sharedImageForTask: SharedContentForTask? {
        guard let selectedImage = selectedImage, uploadedImageLink != "" else {
            return nil
        }
        
        return SharedContentForTask(image: selectedImage, uploadedLink: uploadedImageLink, coordinates: imageCoordinates)
    }
    
    private var uploadedImageLink = ""
    private var taskProcessManager = TaskProcessManager.shared
    private let openAiServiceHelper = OpenAIServiceHelper()
    private let imageProcessingManager = ImageProcessingManager()

    @State private var selectedImageURLS: [URL] = []
    @State private var selectedImages: [Image] = []

    @MainActor
    func convertDataToImage() {
        selectedImage = nil
        
        if !selectedPhotos.isEmpty {
            for eachItem in selectedPhotos {
                Task {
                    if let imageData = try? await eachItem.loadTransferable(type: Data.self) {
                        if let image = UIImage(data: imageData) {
                            self.selectedImage = image
                            self.extractMetaData(from: imageData)
                        }
                    }
                }
            }
        }
        selectedPhotos.removeAll()
        state = .imageSelected
    }
    
    func createTasksWithPrompt() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            imageBasedTask = try await imageProcessingManager.createTasksWithContextPrompt(
                prompt: promptText, 
                excludedTaskTypes: excludedTaskType
            )
            taskProcessManager.currentTaskId = imageBasedTask?.id ?? ""
            if let task = imageBasedTask {
                try? await taskProcessManager.createUserResultPerformance(task: task)
            }
            state = .taskAvailable
        } catch {
            print("createTasksWithPrompt error: ", error.localizedDescription)
        }
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
        print("excludedTaskTypes")
        print(excludedTaskType.description)
        imageBasedTask = try await imageProcessingManager.createImageBasedTask(
            imageUrl: uploadedImageLink,
            excludedTaskTypes: excludedTaskType,
            imageLocation: imageCoordinates
        )
        taskProcessManager.currentTaskId = imageBasedTask?.id ?? ""
    }
    
    @MainActor
    func fetchPerformance() async {
        print("fetchPerformance")
        userPerformance =  try? await taskProcessManager.fetchUserTaskPerformance()
        print(userPerformance)
        areAllTaskDone = userPerformance?.isTaskDone() ?? false
    }
    
    func openCamera() {
        showCamera.toggle()
        let locationManager = LocationManager()
        let position = locationManager.lastKnownLocation
        imageCoordinates = Location(latitude: position?.latitude ?? 0, longitude: position?.longitude ?? 0)
    }
    
    func extractMetaData(from imageData: Data) {
        
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] else {
            print("Failed to extract metadata")
            return
        }
                
        guard let gpsMetadata = metadata[kCGImagePropertyGPSDictionary as String] as? [String: Any] else {
            print("NO GPS DATA")
            return
        }
        let latitude = (gpsMetadata["Latitude"] as? Double) ?? 0
        let longitude = (gpsMetadata["Longitude"] as? Double) ?? 0

        imageCoordinates = Location(latitude: latitude, longitude: longitude)
        print("imageCoordinates")
        print(imageCoordinates)
    }
}
