import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    @State var player: AVAudioPlayer
    @State private var isPlaying = false
    @State private var totalTime: TimeInterval
    @State private var currentTime: TimeInterval = 0.0
    
    init(player: AVAudioPlayer){
        self.player = player
        totalTime = player.duration
    }

    var body: some View {
        VStack {
                Text("Title for Audio")
                HStack {
                    Button(
                        action: {
                            tootglePlayButton()
                        },
                        label: {
                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.largeTitle)
                        }).buttonStyle(PlainButtonStyle())
                    
                    Slider(
                        value: Binding(get: { currentTime }, set: { newValue in
                            player.currentTime = newValue
                        currentTime = newValue
                    }), in: 0...totalTime)
                    .accentColor(.blue)
                }
                HStack {
                    Text("\(formatTime(currentTime))")
                    Spacer()
                    Text("\(formatTime(totalTime))")
                }
                .padding(.horizontal)
        }
        .onReceive(Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()) { _ in
            updateProgress()
        }
        .onDisappear {
            player.stop()
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let seconds = Int(time) % 60
        let minutes = Int(time) / 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func updateProgress() {
        currentTime = player.currentTime
    }
    
    private func tootglePlayButton() {
        isPlaying.toggle()
        if isPlaying {
            player.play()
        } else {
            player.pause()
        }
    }
}
