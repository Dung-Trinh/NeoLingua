import Combine

protocol WriteVocabularyViewModel: ObservableObject {}

class WriteVocabularyViewModelImpl: WriteVocabularyViewModel {

    var exercises: [VocabularyTrainingProtocol]
    var exercise: VocabularyTrainingProtocol

    @Published var userInputText: String = ""

    @Published var currentQuestionIndex = 0
    @Published var isSheetPresented: Bool = false
    @Published var sheetViewModel: ResultSheetViewModel?

    let exercise1 = WriteWordExercise(
        question: "Was ist das englische Wort für 'Hund'?",
        answer: "dog",
        translation: "Hund"
    )
    let exercise2 = SentenceBuildingExercise(
        question: "Ordne die Wörter in der richtigen Reihenfolge.",
        sentenceComponents: ["This", "is", "a", "house"],
        answer: "This is a house", translation: "Das ist ein Haus"
    )
    let exercise3 = ChooseWordExercise(
        question: "Wähle das richtige Wort.",
        words: ["dog", "cat", "mouse"],
        answer: "dog",
        translation: "Hund"
    )// TODO: View dafür entwickeln
    
    init() {
        exercises = [exercise1, exercise2, exercise3]
        exercise = exercises[0]
    }
    
    func checkAnswerTapped() {
        guard !userInputText.isEmpty else {
            print("userInputText leer")
            return
        }
        var userFeedbackText = ""
        var isAnswerCorrect = false

        print("Vergleich")
        print(userInputText)
        print(exercise.answer)

        if exercise.checkAnswer(userInputText) {
            isAnswerCorrect = true
            userFeedbackText = "Richtig! Die deutsche Übersetzung ist: \(exercise.translation)"
        } else {
            isAnswerCorrect = false
            userFeedbackText = "Falsch. Die richtige Antwort ist: \(exercise.answer), auf Deutsch: \(exercise.translation)"
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
        if currentQuestionIndex < exercises.count - 1 {
            currentQuestionIndex += 1
            exercise = exercises[currentQuestionIndex]
            userInputText = ""
        } else {
            // keine Fragen mehr
        }
    }
}
