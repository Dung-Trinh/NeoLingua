import Foundation
import Combine
import SwiftOpenAI
import AVFoundation
import Speech

enum ConversationInputMode: String, CaseIterable {
    case speech = "Speaking"
    case text = "Writing"
}

enum ConversationState {
    case start
    case roleSelection
    case conversation
    case evaluation
    case contextDescription
}

protocol ConversationSimulationPageViewModel: ObservableObject {
    var conversationState: ConversationState { get set }
    var roleOptionsResponse: RoleOptionsResponse? { get }
    var isResultSheetPresented: Bool { get set }
    var taskPerformance: TaskPerformancetParameter? { get }
    var selectedRole: RoleOption? { get }
    var isRecording: Bool { get }
    var audioPlayer: AudioPlayer { get set }
    var selectedMode: ConversationInputMode{ get set }
    var messageText: String { get set }
    var isLoading: Bool { get }
    var lastConversationResponse: ConversationResponse? { get }
    var lastUserMessage: String { get }
    var conversationEvaluation: ConversationEvaluation? { get }
    var isEvaluationSheetPresented: Bool { get set }
    
    func selectedRole(role: RoleOption) async
    func sendMessage(message: String) async
    func startRecording()
    func endRecording()
    func getConversationEvaluation() async
}

class ConversationSimulationPageViewModelImpl: ConversationSimulationPageViewModel {
    private var cancellables = Set<AnyCancellable>()
    private let service: OpenAIService
    private let conversationSimulationManager = ConversationSimulationManager()
    private let prompt: String
    private var taskProcessManager = TaskProcessManager.shared
    
    @Published var speechRecognizer = SpeechRecognizer()
    @Published var isRecording = false
    @Published var messageText = ""
    @Published var lastUserMessage = ""
    @Published var lastConversationResponse: ConversationResponse?
    @Published var roleOptionsResponse: RoleOptionsResponse?
    @Published var audioPlayer = AudioPlayer()
    @Published var conversationState: ConversationState = .start
    @Published var conversationEvaluation: ConversationEvaluation?
    @Published var isEvaluationSheetPresented = false
    @Published var selectedMode: ConversationInputMode = .speech
    @Published var selectedRole: RoleOption?
    @Published var isLoading: Bool = false
    @Published var taskPerformance: TaskPerformancetParameter?
    @Published var isResultSheetPresented = false
    var isScavengerHuntMode: Bool = false
    
    init(prompt: String) {
        self.prompt = prompt
        service = OpenAIServiceProvider.shared
        Task {
            await createConversationSimulation()
        }
    }
    
    @MainActor
    func sendMessage(message: String) async {
        isLoading = true
        lastConversationResponse = nil
        defer { isLoading = false }
        print("sendMessage: ", message)
        do {
            lastUserMessage = messageText
            let result = try await conversationSimulationManager.sendMessageAndGetResponse(message: message)
            lastConversationResponse = result
            try await audioPlayer.createSpeech(textForSpeech: result?.answer ?? "")
            audioPlayer.playAudio()
            conversationState = .conversation
            if result?.endOfConversation == true {
                print("conversationState", conversationState)
                conversationState = .evaluation
            }
            print("Antwort: ", result)
            messageText = ""
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
    }
    
    func selectedRole(role: RoleOption) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            selectedRole = role
            let result = try await conversationSimulationManager.selectedRole(selectedRole: role)
            try await audioPlayer.createSpeech(textForSpeech: result?.introText ?? "")
            audioPlayer.playAudio()
            conversationState = .conversation
        } catch {
            print("audioPlayer.createSpeech error: ", error.localizedDescription)
        }
    }
    
    func getConversationEvaluation() async {
        isLoading = true
        
        do {
            let result = try await conversationSimulationManager.fetchEvaluation()
            conversationEvaluation = result
            conversationState = .evaluation
            let finalPoints = (Double((conversationEvaluation?.rating ?? 0) / 10)) * 40
            let parameter = TaskPerformancetParameter(result: Double((conversationEvaluation?.rating ?? 0) / 10),isDone: true, finalPoints: finalPoints)
            taskPerformance = parameter
            if isScavengerHuntMode {
                try await taskProcessManager.updateScavengerHuntState(parameter: parameter, taskType: .conversationSimulation)
            } else {
                try await taskProcessManager.updateTaskPerformance(parameter: parameter, taskType: .conversationSimulation)
            }
            
            isLoading = false
            isEvaluationSheetPresented = true
        } catch {
            print("getConversationEvaluation() error: ", error.localizedDescription)
        }
    }
    
    private func createConversationSimulation() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await conversationSimulationManager.createConversation(prompt: prompt)
            roleOptionsResponse = result
            conversationState = .contextDescription
        } catch {
            print("createConversationSimulation() error: ", error.localizedDescription)
        }
    }
}
