import SwiftUI
import FirebaseStorage
import Firebase

struct SharedImageTask: Codable, Identifiable {
    let id: String
    let userId: String
    let coordinates: Location
    let imageUrl: String
    let vocabulary: [String]
}

protocol ImageBasedTaskNearMePageViewModel: ObservableObject {
    
}

class ImageBasedTaskNearMePageViewModelImpl: ImageBasedTaskNearMePageViewModel {
    @Published var allTasks: [SharedImageTask] = []
    
    @Published var sharedImageTask: SharedImageTask?
    @Published var userInput: String = ""
    @Published var lastUserInput: String = ""
    @Published var showHintButton: Bool = false
    @Published var hint: String = ""
    @Published var isFirstValidation: Bool = true
    
    @Published var result: InspectImageForVocabularyResult?
    private var imageProcessingManager = ImageProcessingManager()
    init() {
        fetchImageBasedTaskNearMe()
    }
    
    func fetchImageBasedTaskNearMe() {
        Task {
            await fetchTasks()
        }
    }
    
    func validateUserInputWithImage() async {
        guard let sharedImageTask = sharedImageTask else { return }
        
        do {
            result = try await imageProcessingManager.verifyTextWithImage(
                imageUrl: sharedImageTask.imageUrl,
                searchedVocabulary: sharedImageTask.vocabulary,
                userInput: userInput
            )
            lastUserInput = userInput
            userInput = ""
            if result?.foundSearchedVocabulary != true || result?.result == .wrong {
                showHintButton = true
            }
        } catch {
            print("validateUserInputWithImage ", error.localizedDescription)
        }
    }
    
    func fetchHint() async {
        do {
            hint = try await imageProcessingManager.fetchImageHint()
            showHintButton = false
            print("hint ", hint)
        } catch {
            print("fetchHint error")
        }
    }
    
    func fetchTasks() async {
        let db = Firestore.firestore()
        do {
            let snapshot = try await db.collection("imageBasedTasks").getDocuments()
            
            self.allTasks = snapshot.documents.compactMap { document in
                try? document.data(as: SharedImageTask.self)
            }
            print("allTasks")
            print(allTasks)
        } catch {
            print("Error fetching tasks: \(error)")
        }
    }
}
