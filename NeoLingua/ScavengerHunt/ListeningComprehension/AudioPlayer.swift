import Foundation
import SwiftOpenAI
import AVFoundation

class AudioPlayer: ObservableObject {
    let service = OpenAIServiceFactory.service(apiKey: ProdENV().OPENAI_KEY)
    @Published var audioPlayer: AVAudioPlayer?
    
    func createSpeech(textForSpeech: String) async throws {
        let parameters = AudioSpeechParameters(
            model: .tts1,
            input: textForSpeech,
            voice: .onyx,
            speed: 1
        )
        let speech = try await service.createSpeech(parameters: parameters).output
        audioPlayer = try AVAudioPlayer(data: speech)
        audioPlayer?.prepareToPlay()
    }
    
    func playAudio(from data: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
}
