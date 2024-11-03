import Combine
import SwiftUI

protocol VocabularyTrainingPageViewModel: ObservableObject {}

class VocabularyTrainingPageViewModelImpl: VocabularyTrainingPageViewModel {
    @Published var tasks: [VocabularyExercise] = []
    @Published var currentTask: VocabularyExercise?
    @Published var userInputText: String = ""
    @Published var currentQuestionIndex = 0
    @Published var isSheetPresented: Bool = false
    @Published var isCheckAnswerButtonHidden: Bool = false
    @Published var sheetViewModel: ResultSheetViewModel?
    @Published var router: Router
    @Published var showResult: Bool = false
    @Published var isLoading: Bool = false

    var isScavengerHuntMode: Bool = false

    private var prompt = ""
    private var vocabularyManager = VocabularyManager()
    private var anyCancellables = Set<AnyCancellable>()
    private var taskProcessManager = TaskProcessManager.shared
    private var points = 0
    init(
        prompt: String,
        router: Router
    ) {
        self.prompt = prompt
        self.router = router
        $currentTask.sink(receiveValue: { value in
            if value?.type == .multipleChoice {
                self.isCheckAnswerButtonHidden = true
            } else {
                self.isCheckAnswerButtonHidden = false
            }
        }).store(in: &anyCancellables)
    }
    
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
            points += 1
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
        sheetViewModel = nil
        isSheetPresented = false
        if currentQuestionIndex < tasks.count - 1 {
            currentQuestionIndex += 1
            currentTask = tasks[currentQuestionIndex]
            userInputText = ""
        } else {
            Task {
                let finalPoints =  Double(points) / Double(points)
                let parameter = TaskPerformancetParameter(result: finalPoints, isDone: true)
                if isScavengerHuntMode {
                    try await taskProcessManager.updateScavengerHuntState(parameter: parameter, taskType: .vocabularyTraining)
                } else {
                    
                    try? await taskProcessManager.updateTaskPerformance(parameter: parameter, taskType: .vocabularyTraining)
                }
            }
            
            print("keine antworten mehr zurück")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    self.showResult = true
                    self.isSheetPresented = true
                }
            }
        }
    }
    
    func fetchVocabularyTraining() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await vocabularyManager.fetchVocabularyTraining(prompt: prompt)
            tasks = result
            currentTask = result.first
            print("fetchVocabularyTraining count: ", result.count)
        } catch {
            print("fetchVocabularyTraining error: ", error.localizedDescription)
        }
    }
}
