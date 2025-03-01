import Combine
import SwiftUI

protocol VocabularyTrainingPageViewModel: ObservableObject {
    var currentTask: VocabularyExercise? { get }
    var userInputText: String { get set }
    var isSheetPresented: Bool { get set }
    var isExplanationSheetPresented: Bool { get set }
    var explanationText: String { get }
    var isCheckAnswerButtonHidden: Bool { get }
    var sheetViewModel: ResultSheetViewModelImpl? { get }
    var showResult: Bool { get }
    var isLoading: Bool { get }
    var showProgressIndicator: Bool { get set }
    var progress: CGFloat { get set }
    var numberOfTasks: Int { get }
    var taskPerformance: TaskPerformancetParameter? { get }
    
    func checkAnswerTapped()
    func fetchVocabularyTraining() async
}

class VocabularyTrainingPageViewModelImpl: VocabularyTrainingPageViewModel {
    private var tasks: [VocabularyExercise] = []
    private var prompt = ""
    private var points = 0
    private var finalPoints: Double = 0
    private var scorePercentage: Double = 0
    private var anyCancellables = Set<AnyCancellable>()
    private var currentQuestionIndex = 0

    private let vocabularyManager = VocabularyManager()
    private let taskProcessManager = TaskProcessManager.shared
    private let router: Router

    @Published var currentTask: VocabularyExercise?
    @Published var userInputText: String = ""
    @Published var isSheetPresented: Bool = false
    @Published var isExplanationSheetPresented: Bool = false
    @Published var explanationText: String = ""
    @Published var isCheckAnswerButtonHidden: Bool = false
    @Published var sheetViewModel: ResultSheetViewModelImpl?
    @Published var showResult: Bool = false
    @Published var isLoading: Bool = false
    @Published var showProgressIndicator: Bool = true
    @Published var progress: CGFloat = 0.0
    @Published var numberOfTasks: Int = 0
    @Published var taskPerformance: TaskPerformancetParameter?
    var isScavengerHuntMode: Bool = false
    
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
            let answer = currentTask?.answer ?? ""
            userFeedbackText = "Falsch. Die richtige Antwort ist: \(answer)"
        }
        
        let showDetailedFeedbackButton = currentTask?.type == .sentenceAssembly && isAnswerCorrect == false
        sheetViewModel = ResultSheetViewModelImpl(
            result: isAnswerCorrect ? .correct : .incorrect,
            text: userFeedbackText,
            action: {
                self.continueTask()
            },
            getDetailedFeedback: {
                Task {
                    await self.getDetailedFeedback()
                }
            },
            showDetailedFeedbackButton: showDetailedFeedbackButton
        )
        isSheetPresented = true
    }
    
    func fetchVocabularyTraining() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await vocabularyManager.fetchVocabularyTraining(prompt: prompt)
            tasks = result
            currentTask = result.first
            numberOfTasks = result.count
            print("fetchVocabularyTraining count: ", result.count)
        } catch {
            print("fetchVocabularyTraining error: ", error.localizedDescription)
        }
    }
    
    private func continueTask() {
        sheetViewModel = nil
        isSheetPresented = false
        progress = CGFloat(currentQuestionIndex + 1) / CGFloat(numberOfTasks)
        if currentQuestionIndex < tasks.count - 1 {
            currentQuestionIndex += 1
            currentTask = tasks[currentQuestionIndex]
            userInputText = ""
        } else {
            Task {
                await calcAndSavePoints()
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
    
    private func getDetailedFeedback() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            explanationText = try await vocabularyManager.getDetailedFeedback(userInput: userInputText, taskId: currentTask?.id ?? "")
            isExplanationSheetPresented = true
        } catch {
            print("getDetailedFeedback error :", error.localizedDescription)
        }
    }
    
    private func calcAndSavePoints() async {
        scorePercentage =  Double(points) / Double(tasks.count)
        finalPoints = scorePercentage * 15
        let parameter = TaskPerformancetParameter(result: scorePercentage, isDone: true, finalPoints: finalPoints)
        taskPerformance = parameter
        if isScavengerHuntMode {
            try? await taskProcessManager.updateScavengerHuntState(parameter: parameter, taskType: .vocabularyTraining)
        } else {
            try? await taskProcessManager.updateTaskPerformance(parameter: parameter, taskType: .vocabularyTraining)
        }
    }
}
