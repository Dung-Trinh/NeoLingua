import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    @Binding var player: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var totalTime: TimeInterval
    @State private var currentTime: TimeInterval = 0.0
    
    init(player: Binding<AVAudioPlayer?>){
        self._player = player
        totalTime = player.wrappedValue?.duration ?? 0
    }
    
    var body: some View {
        VStack {
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
                        player?.currentTime = newValue 
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
        .onChange(of: player) { newPlayer in
            totalTime = newPlayer?.duration ?? 0
            currentTime = 0
            isPlaying = newPlayer?.isPlaying ?? false
        }
        .onReceive(Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()) { _ in
            updateProgress()
        }
        .onDisappear {
            player?.stop()
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let seconds = Int(time) % 60
        let minutes = Int(time) / 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func updateProgress() {
        currentTime = player?.currentTime ?? 0
    }
    
    private func tootglePlayButton() {
        isPlaying.toggle()
        if isPlaying {
            player?.play()
        } else {
            player?.pause()
        }
    }
}
