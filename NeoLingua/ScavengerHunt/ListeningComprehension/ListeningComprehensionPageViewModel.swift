import AVFoundation
import SwiftOpenAI

protocol ListeningComprehensionPageViewModel: ObservableObject {
    
}

class ListeningComprehensionPageViewModelImpl: ListeningComprehensionPageViewModel {
    @Published var isLoading = false
    @Published var isSheetPresented = false
    @Published var userInput = ""
    @Published var answers: [String] = []
    @Published var audioPlayer = AudioPlayer()
    @Published var exercise: ListeningExercise?
    @Published var evaluation: ListeningTaskEvaluation?
    @Published var evaluatedQuestion: [EvaluatedQuestion] = []
    @Published var taskPerformance: TaskPerformancetParameter?

    let prompt: String
    var isScavengerHuntMode: Bool = false

    private let service: OpenAIService
    private let listeningComprehensionManager = ListeningComprehensionManager()
    private var taskProcessManager = TaskProcessManager.shared

    init(prompt: String) {
        self.prompt = prompt
        service = OpenAIServiceFactory.service(apiKey: ProdENV().OPENAI_KEY)
    }
    
    func fetchListeningComprehensionTask() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            exercise = try await listeningComprehensionManager.fetchListeningComprehensionTask(prompt: prompt)
            if let exercise {
                for _ in 0..<exercise.listeningQuestions.count {
                    answers.append("")
                }
            }

            await createSpeech()
        } catch {
            print("fetchListeningComprehensionTask error: ", error.localizedDescription)
        }
    }
    
    private func createSpeech() async {
        var speechErrorMessage = ""
        do {
            try await audioPlayer.createSpeech(textForSpeech: exercise?.textForSpeech ?? "no text for speech error")
            audioPlayer.audioPlayer?.prepareToPlay()
        } catch let error as APIError {
            speechErrorMessage = error.displayDescription
        } catch {
            speechErrorMessage = "\(error)"
        }
        print(speechErrorMessage)
    }
    
    func evaluateQuestions() async {
        isLoading = true
        defer { isLoading = false }
        
        var userInputs: [String] = []
        exercise?.listeningQuestions.enumerated().forEach { (index, question) in
            if answers.count > index {
                userInputs.append("task \(question.id) = \(answers[index])")
            }
        }
        print("userResult: ")
        let finalResult = userInputs.joined(separator: ",")
        
        do {
            evaluation = try await listeningComprehensionManager.fetchListeningTaskEvaluation(userAnswer: finalResult)
            evaluatedQuestion = evaluation?.evaluatedQuestions ?? []
            
            guard let evaluation else{
                print("keine evaluation")
                return
            }
            
            let resultPercentage = evaluation.getScorePercentage()
            let points = Double(evaluation.getScorePercentage() * 30)
            let parameter = TaskPerformancetParameter(result: resultPercentage, isDone: true, finalPoints: points)
            taskPerformance = parameter
            isSheetPresented = true

            print(points)
            if isScavengerHuntMode {
                try await taskProcessManager.updateScavengerHuntState(parameter: parameter, taskType: .listeningComprehension)
            } else {
                try await taskProcessManager.updateTaskPerformance(parameter: parameter, taskType: .listeningComprehension)
            }
        } catch {
            print("evaluateQuestions error: ", error.localizedDescription)
        }
    }
}
