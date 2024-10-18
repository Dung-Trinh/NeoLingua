import Combine

protocol VocabularyTrainingPageViewModel: ObservableObject {}

class VocabularyTrainingPageViewModelImpl: VocabularyTrainingPageViewModel {
    @Published var tasks: [VocabularyExercise] = []
    @Published var currentTask: VocabularyExercise?
    @Published var userInputText: String = ""
    @Published var currentQuestionIndex = 0
    @Published var isSheetPresented: Bool = false
    @Published var sheetViewModel: ResultSheetViewModel?
    
    private var vocabularyManager = VocabularyManager()
    
    func checkAnswerTapped() {
        guard !userInputText.isEmpty else {
            print("userInputText leer")
            return
        }
        var userFeedbackText = ""
        var isAnswerCorrect = false

        if let currentTask = currentTask, currentTask.checkAnswer(userInputText) {
            isAnswerCorrect = true
            userFeedbackText = "Richtig! Die deutsche Übersetzung ist: \(currentTask.translation)"
        } else {
            isAnswerCorrect = false
            userFeedbackText = "Falsch. Die richtige Antwort ist: \(currentTask?.answer), auf Deutsch: \(currentTask?.translation)"
        }

        sheetViewModel = ResultSheetViewModel(
            result: isAnswerCorrect ? .correct : .incorrect,
            text: userFeedbackText,
            action: {
                self.continueTask()
            }
        )
        isSheetPresented = true
    }
    
    func continueTask() {
        isSheetPresented = false
        if currentQuestionIndex < tasks.count - 1 {
            currentQuestionIndex += 1
            currentTask = tasks[currentQuestionIndex]
            userInputText = ""
        } else {
            // keine Fragen mehr
        }
    }
    
    func fetchVocabularyTraining() async {
        do {
            let result = try await vocabularyManager.fetchVocabularyTraining()
            tasks = result
            currentTask = result.first
            print("fetchVocabularyTraining count: ", result.count)
        } catch {
            print("fetchVocabularyTraining error: ", error.localizedDescription)
        }
    }
}
