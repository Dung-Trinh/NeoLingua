import AVFoundation
import SwiftOpenAI

protocol ListeningComprehensionPageViewModel: ObservableObject {
    
}

class ListeningComprehensionPageViewModelImpl: ListeningComprehensionPageViewModel {
    @Published var isLoading = false
    @Published var userInput = ""
    @Published var answers: [String] = []
    @Published var audioPlayer: AVAudioPlayer?
    @Published var exercise: ListeningExercise?
    @Published var evaluation: ListeningTaskEvaluation?
    let prompt: String

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

            //await createSpeech()
        } catch {
            print("fetchListeningComprehensionTask error: ", error.localizedDescription)
        }
    }
    
    private func createSpeech() async {
        var speechErrorMessage = ""
        do {
            let speech = try await listeningComprehensionManager.createSpeech(text: exercise?.textForSpeech ?? "no text for speech")
            audioPlayer = try AVAudioPlayer(data: speech)
            audioPlayer?.prepareToPlay()
        } catch let error as APIError {
            speechErrorMessage = error.displayDescription
        } catch {
            speechErrorMessage = "\(error)"
        }
        print(speechErrorMessage)
    }
    
    func evaluateQuestions() async {
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
            
            guard let evaluation else{
                print("keine evaluation")
                return
            }
            
            let points = Double ((evaluation.countCorrectAnswers())/evaluation.evaluatedQuestions.count)
            
            let parameter = TaskPerformancetParameter(result: points)
            
            try await taskProcessManager.updateTaskPerformance(parameter: parameter, taskType: .listeningComprehension)
        } catch {
            print("evaluateQuestions error: ", error.localizedDescription)
        }
    }
}
