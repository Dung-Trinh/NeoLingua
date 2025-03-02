import Combine

protocol SnapVocabularyTaskPageViewModel: ObservableObject {
    var sharedImageTask: SnapVocabularyTask { get }
    var userInput: String { get set }
    var result: InspectImageForVocabularyResult? { get }
    var lastUserInput: String { get }
    var showHintButton: Bool { get }
    var hint: String { get }
    var isLoading: Bool { get }
    var finalPoints: Double { get }
    
    func fetchHint() async
    func validateUserInputWithImage() async
}

class SnapVocabularyTaskPageViewModelImpl: SnapVocabularyTaskPageViewModel {
    private let imageProcessingManager = ImageProcessingManager()
    private let leaderboardService = LeaderboardServiceImpl()
    private var numberOfAttempts = -1.0
    
    @Published var sharedImageTask: SnapVocabularyTask
    @Published var userInput: String = ""
    @Published var lastUserInput: String = ""
    @Published var hint: String = ""
    @Published var result: InspectImageForVocabularyResult?
    @Published var showHintButton: Bool = false
    @Published var isLoading: Bool = false
    @Published var finalPoints: Double = 0
    @Published var showResultSheet: Bool = false
    
    init(sharedImageTask: SnapVocabularyTask) {
        self.sharedImageTask = sharedImageTask
    }
    
    func addPointsToLeaderboard() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            hint = try await imageProcessingManager.fetchImageHint()
            showHintButton = false
            print("hint ", hint)
        } catch {
            print("addPointsToLeaderboard error")
        }
    }
    
    func fetchHint() async {
        isLoading = true
        defer { isLoading = false }
        
        result = nil
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
        
        hint = ""
        do {
            result = try await imageProcessingManager.verifyTextWithImage(
                imageUrl: sharedImageTask.imageUrl,
                searchedVocabulary: sharedImageTask.vocabulary,
                userInput: userInput
            )
            numberOfAttempts += 1
            lastUserInput = userInput
            userInput = ""
            if result?.foundSearchedVocabulary != true || result?.result == .wrong {
                showHintButton = true
            } else if result?.foundSearchedVocabulary == true {
                finalPoints = (numberOfAttempts * 0.5) + (result?.points ?? 0)
                try await leaderboardService.addPointsForLevel(points: finalPoints)
            }
        } catch {
            print("validateUserInputWithImage ", error.localizedDescription)
        }
    }
}
