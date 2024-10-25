import Foundation
import Combine
import SwiftOpenAI
import AVFoundation
import Speech

enum ConversationState {
    case start
    case roleSelection
    case conversation
    case evaluation
}

protocol ConversationSimulationPageViewModel: ObservableObject {
    
}

class ConversationSimulationPageViewModelImpl: ConversationSimulationPageViewModel {
    private var cancellables = Set<AnyCancellable>()
    private let service: OpenAIService
    let conversationSimulationManager = ConversationSimulationManager()
    @Published var speechRecognizer = SpeechRecognizer()
    @Published var isRecording = false
    @Published var messageText = ""
    @Published var roleOptionsResponse: RoleOptionsResponse?
    @Published var audioPlayer = AudioPlayer()
    @Published var conversationState: ConversationState = .start
    @Published var conversationEvaluation: ConversationEvaluation?
    let prompt: String
    private var taskProcessManager = TaskProcessManager.shared

    init(prompt: String) {
        self.prompt = prompt
        service = OpenAIServiceProvider.shared
//        Task {
//            await createConversationSimulation()
//        }
        
        conversationState = .evaluation
        conversationEvaluation = TestData.conversationEvaluation
    }
    
    @MainActor 
    func sendMessage(message: String) async {
//        let message = speechRecognizer.transcript
        print("sendMessage: ", message)
        do {
            let result = try await conversationSimulationManager.sendMessageAndGetResponse(message: message)
            if result?.endOfConversation == true {
                print("conversationState", conversationState)
                conversationState = .evaluation
            }
            print("Antwort: ", result)
        } catch {
            print("sendMessage error: ", error.localizedDescription)
        }
    }
    
    @MainActor 
    func startRecording() {
        speechRecognizer.resetTranscript()
        speechRecognizer.startTranscribing()
        isRecording = true
    }
    
    @MainActor 
    func endRecording() {
        speechRecognizer.stopTranscribing()
        isRecording = false
        print("Stopped", speechRecognizer.transcript)
        print("speechRecognizer.transcript")
        print(speechRecognizer.transcript)
        messageText = speechRecognizer.transcript
        // for later
//        Task {
//            await sendMessage(message: speechRecognizer.transcript)
//        }
    }
    
    func selectedRole(role: RoleOption) async {
            do {
                let result = try await conversationSimulationManager.selectedRole(selectedRole: role)
                // for later
//                try await audioPlayer.createSpeech(textForSpeech: result?.introText ?? "")
//                audioPlayer.audioPlayer?.prepareToPlay()
//                audioPlayer.audioPlayer?.play()
                    print("selectedRole RESULT")
                    print(result)
                conversationState = .conversation
            } catch {
                print("audioPlayer.createSpeech error: ", error.localizedDescription)
            }
        }
    
    func createConversationSimulation() async {
        do {
            let result = try await conversationSimulationManager.createConversation(prompt: prompt)
            roleOptionsResponse = result
            conversationState = .roleSelection
        } catch {
            print("createConversationSimulation() error: ", error.localizedDescription)
        }
    }
    
    func getConversationEvaluation() async {
        do {
//            let result = try await conversationSimulationManager.fetchEvaluation()
//            print("getConversationEvaluation()")
//            print(result)
//            conversationEvaluation = result
            
            let parameter = TaskPerformancetParameter(result: Double((conversationEvaluation?.rating ?? 0) / 10))
            try? await taskProcessManager.updateTaskPerformance(parameter: parameter, taskType: .conversationSimulation)
        } catch {
            print("getConversationEvaluation() error: ", error.localizedDescription)
        }
    }
}
