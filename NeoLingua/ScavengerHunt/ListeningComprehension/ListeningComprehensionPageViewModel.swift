import AVFoundation
import SwiftOpenAI

protocol ListeningComprehensionPageViewModel: ObservableObject {
    
}

class ListeningComprehensionPageViewModelImpl: ListeningComprehensionPageViewModel {
    @Published var isLoading = false
    @Published var prompt = ""
    @Published var audioPlayer: AVAudioPlayer?
    var service: OpenAIService
    
    let textForSpeech: String = "Nestled in the heart of the town, the Kurpark offers a serene escape from the bustle of daily life, where visitors can rejuvenate both body and mind amidst meticulously landscaped gardens and natural springs.The park's harmonious blend of historic architecture and modern amenities creates a unique environment that fosters relaxation, wellness, and a deep connection to nature."
    
    init() {
        service = OpenAIServiceFactory.service(apiKey: ProdENV().OPENAI_KEY)
    }
    
    func createSpeech() async {
        isLoading = true
        defer { isLoading = false }
        
        var speechErrorMessage = ""
        do {
            let parameters = AudioSpeechParameters(
                model: .tts1,
                input: textForSpeech,
                voice: .shimmer,
                speed: 0.8
            )
            let speech = try await service.createSpeech(parameters: parameters).output
            audioPlayer = try AVAudioPlayer(data: speech)
            audioPlayer?.prepareToPlay()
        } catch let error as APIError {
            speechErrorMessage = error.displayDescription
        } catch {
            speechErrorMessage = "\(error)"
        }
        print(speechErrorMessage)
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
