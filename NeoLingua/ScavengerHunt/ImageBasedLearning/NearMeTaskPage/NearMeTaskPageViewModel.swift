import Combine

protocol NearMeTaskPageViewModel: ObservableObject {
    
}

class NearMeTaskPageViewModelImpl: NearMeTaskPageViewModel {
    @Published var sharedImageTask: SnapVocabularyTask
    @Published var userInput: String = ""
    @Published var lastUserInput: String = ""
    @Published var hint: String = ""
    @Published var result: InspectImageForVocabularyResult?
    @Published var showHintButton: Bool = false
    @Published var isLoading: Bool = false

    private var imageProcessingManager = ImageProcessingManager()
    
    init(sharedImageTask: SnapVocabularyTask) {
        self.sharedImageTask = sharedImageTask
    }
    
    func fetchHint() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            hint = try await imageProcessingManager.fetchImageHint()
            showHintButton = false
            print("hint ", hint)
        } catch {
            print("fetchHint error")
        }
    }
    
    func validateUserInputWithImage() async {
        isLoading = true
        defer { isLoading = false }
        
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
}
