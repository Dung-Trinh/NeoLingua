import Foundation
import Alamofire
import SwiftOpenAI
import FirebaseStorage
import _PhotosUI_SwiftUI
import SwiftUI
import Combine

struct SharedContentForTask: Hashable {
    let image: UIImage
    let uploadedLink: String
    let coordinates: Location?
}

enum ContexBasedLearningPageState {
    case initialState
    case imageSelected
    case taskAvailable
}

protocol ContextBasedLearningPageViewModel: ObservableObject {
    var selectedPhotos: [PhotosPickerItem] { get set }
    var selectedImage: UIImage? { get set }
    var imageBasedTask: ImageBasedTask? { get }
    var userPerformance: UserTaskPerformance? { get }
    var isSheetPresented: Bool { get }
    var state: ContexBasedLearningPageState { get }
    var isLoading: Bool { get }
    var areAllTaskDone: Bool { get }
    var showCamera: Bool { get set }
    var excludedTaskType: [TaskType] { get set }
    var promptText: String { get set }
    var shouldShowPromptInput: Bool { get set }
    var sharedImageForTask: SharedContentForTask? { get }
    
    func openCamera()
    func fetchPerformance() async
    func analyzeImage() async
    func createTasksWithPrompt() async
    func convertDataToImage()
    func navigateTo(_ route: Route)
}

class ContextBasedLearningPageViewModelImpl: ContextBasedLearningPageViewModel {
    private var router: Router
    private var cancellables = Set<AnyCancellable>()
    private var imageCoordinates: Location?
    private var uploadedImageLink = ""
    private var taskProcessManager = TaskProcessManager.shared
    private var selectedImageURLS: [URL] = []
    private var selectedImages: [Image] = []
    private let openAiServiceHelper = OpenAIManager()
    private let imageProcessingManager = ImageProcessingManager()
    private let firebaseDataManager = FirebaseDataManagerImpl()
    
    @Published var selectedPhotos: [PhotosPickerItem] = []
    @Published var selectedImage: UIImage? = nil
    @Published var imageBasedTask: ImageBasedTask?
    @Published var userPerformance: UserTaskPerformance?
    @Published var isSheetPresented: Bool = false
    @Published var state: ContexBasedLearningPageState = .initialState
    @Published var isLoading: Bool = false
    @Published var areAllTaskDone: Bool = false
    @Published var showCamera = false
    @Published var excludedTaskType: [TaskType] = []
    @Published var promptText: String = ""
    @Published var shouldShowPromptInput = false
    var sharedImageForTask: SharedContentForTask? {
        guard let selectedImage = selectedImage, uploadedImageLink != "" else {
            return nil
        }
        
        return SharedContentForTask(image: selectedImage, uploadedLink: uploadedImageLink, coordinates: imageCoordinates)
    }
    
    init(router: Router) {
        self.router = router
        $selectedImage
            .sink { [weak self] newImage in
                if newImage != nil {
                    self?.state = .imageSelected
                }
            }
            .store(in: &cancellables)
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
                            self.extractMetaData(from: imageData)
                        }
                    }
                }
            }
        }
        selectedPhotos.removeAll()
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
            uploadedImageLink = await firebaseDataManager.generateDownloadURL(selectedImage: selectedImage)
            print("LINK: ",uploadedImageLink)
            try await createImageBasedTask()
            if let task = imageBasedTask {
                try? await taskProcessManager.createUserResultPerformance(task: task)
            }
            state = .taskAvailable
        } catch {
            print("analyzeImage error: ", error.localizedDescription)
        }
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
    
    func navigateTo(_ route: Route) {
        router.push(route)
    }
    
    private func extractMetaData(from imageData: Data) {
        
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
}
