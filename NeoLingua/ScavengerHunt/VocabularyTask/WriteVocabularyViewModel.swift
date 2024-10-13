import Combine

protocol WriteVocabularyViewModel: ObservableObject {}

class WriteVocabularyViewModelImpl: WriteVocabularyViewModel {
    let questions: [VocabularyQuestion] = [
        VocabularyQuestion(text: "The Spielbank Wiesbaden is a well-known ______ where people go to gamble.", answer: "casino", translation: "Kasino"),
        VocabularyQuestion(text: "A ______ is a place where you can borrow and read books.", answer: "library", translation: "Bibliothek")
    ]
    
    @Published var currentQuestion: VocabularyQuestion
    @Published var userInputText: String = ""

    @Published var currentQuestionIndex = 0
    @Published var isSheetPresented: Bool = false
    @Published var sheetViewModel: ResultSheetViewModel?

    init() {
        currentQuestion = questions[0]
    }
    
    func checkAnswerTapped() {
        guard !userInputText.isEmpty else {
            return
        }
        var userFeedbackText = ""
        var isAnswerCorrect = false

        if userInputText.lowercased() == currentQuestion.answer.lowercased() {
            isAnswerCorrect = true
            userFeedbackText = "Richtig! Die deutsche Übersetzung ist: \(currentQuestion.translation)"
        } else {
            isAnswerCorrect = false
            userFeedbackText = "Falsch. Die richtige Antwort ist: \(currentQuestion.answer), auf Deutsch: \(currentQuestion.translation)"
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
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            currentQuestion = questions[currentQuestionIndex]
            userInputText = ""
        } else {
            // keine Fragen mehr
        }
    }
}
