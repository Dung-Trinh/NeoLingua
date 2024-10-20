import SwiftUI
import SwiftOpenAI

struct ListeningComprehensionPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel = ListeningComprehensionPageViewModelImpl()
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Aufgabenstellung")
                if let player = viewModel.audioPlayer {
                    AudioPlayerView(player: player)
                }
                if let exercise = viewModel.exercise {
                    VStack {
                        Text("textForSpeech")
                        Text(exercise.textForSpeech)
                        Text("listeningQuestions")
                        Text(exercise.listeningQuestions.description)
                        
                        ForEach(exercise.listeningQuestions.indices, id: \.self) { index in
                            VStack(alignment: .leading) {
                                Text(exercise.listeningQuestions[index].question)
                                    .font(.subheadline)
                                
                                if viewModel.answers.count > index {
                                    TextField("Your answer...", text: $viewModel.answers[index])
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding(.vertical, 10)
                                }
                            }
                        }
                    }
                }
                TextField("Solution", text: $viewModel.userInput)
                
                if let evaluation = viewModel.evaluation {
                    ScrollView {
                        VStack {
                            Text("evaluatedQuestions")
                            Text(evaluation.evaluatedQuestions.description)
                        }
                    }
                }
                Button("auswerten") {
                    Task {
                        await viewModel.evaluateQuestions()
                    }
                }
            }
            
            .navigationDestination(for: Route.self) { route in
                router.destination(for: route)
            }
        }
        .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
        .onFirstAppear {
            Task {
                await viewModel.fetchListeningComprehensionTask()
            }
        }
    }
}
