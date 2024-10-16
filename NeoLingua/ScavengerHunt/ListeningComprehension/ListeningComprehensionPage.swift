import SwiftUI
import SwiftOpenAI

struct ListeningComprehensionPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel = ListeningComprehensionPageViewModelImpl()
    
    var body: some View {
        VStack {
            Text("Aufgabenstellung")
            if let player = viewModel.audioPlayer {
                AudioPlayerView(player: player)
            }
        }
        .onAppear{
            Task {
                await viewModel.createSpeech()
            }
        }
        .navigationDestination(for: Route.self) { route in
            router.destination(for: route)
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    EmptyView()
                }
            }
        )
    }
}
