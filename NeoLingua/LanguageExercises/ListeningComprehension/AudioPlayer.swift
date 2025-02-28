import Foundation
import SwiftOpenAI
import AVFoundation

class AudioPlayer: ObservableObject {
    let service = OpenAIServiceProvider.shared
    @Published var audioPlayer: AVAudioPlayer?
    
    func createSpeech(textForSpeech: String) async throws {
        if CommandLine.arguments.contains("--useMockData") {
            return
        }

        var speed = 1.0
        let languageLevel = UserDefaults().getLevelOfLanguage()
        switch languageLevel {
        case .A1, .A2:
            speed = 0.9
        case .B1, .B2:
            speed = 1
        case .C1, .C2:
            speed = 1.15
        }
        
        let parameters = AudioSpeechParameters(
            model: .tts1,
            input: textForSpeech,
            voice: .onyx,
            speed: speed
        )
        let speech = try await service.createSpeech(parameters: parameters).output
        audioPlayer = try AVAudioPlayer(data: speech)
        audioPlayer?.prepareToPlay()
    }
    
    func playAudio() {
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
    }
}
