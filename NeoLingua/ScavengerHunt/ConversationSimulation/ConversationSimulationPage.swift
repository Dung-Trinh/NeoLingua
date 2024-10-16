import SwiftUI

struct ConversationSimulationPage: View {
    @EnvironmentObject private var router: Router
    @StateObject private var viewModel = ConversationSimulationPageViewModelImpl()
    
    var body: some View {
        VStack {
            VStack {
                VStack {
                    if viewModel.conversationState == .roleSelection {
                        if let roleOptions = viewModel.roleOptionsResponse {
                            ForEach(roleOptions.roleOptions) { role in
                                Button(role.role) {
                                    Task {
                                        await viewModel.selectedRole(role: role)
                                    }
                                }
                                Text(role.tasks.description)
                            }
                        }
                    }
                }
                
                if let player = viewModel.audioPlayer.audioPlayer {
                    AudioPlayerView(player: player)
                }
                
                Button {
                    viewModel.endRecording()
                } label: {
                    if viewModel.isRecording {
                        CircleLoadingAnimation()
                        
                    }
                    
                    Image(systemName: "mic.circle")
                        .frame(height: 100)
                        .font(.system(size: 70))
                        .padding()
                }
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.1).onEnded { _ in
                        viewModel.startRecording()
                    })
                TextField("Eingabe", text: $viewModel.messageText)
                Button("sendMessage") {
                    Task {
                        await viewModel.sendMessage(message: viewModel.messageText)
                    }
                }
                if viewModel.conversationState == .evaluation {
                    Button("get evaluation") {
                        Task {
                            await viewModel.getConversationEvaluation()
                        }
                    }
                    if let evaluation = viewModel.conversationEvaluation {
                        ScrollView {
                            VStack {
                                Text("grammar: \(evaluation.grammar)")
                                Text("wordChoice: \(evaluation.wordChoice)")
                                Text("structure: \(evaluation.structure)")
                                Text("tasksCompletion: \(evaluation.tasksCompletion.description)")
                                Text("rating: \(evaluation.rating)")
                            }
                        }
                    }
                }
                
            }.padding()
        }.navigationDestination(for: Route.self) { route in
            router.destination(for: route)
        }
    }
}

struct CircleLoadingAnimation: View {
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .trim(from: 0.1, to: 0.7)
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: [.blue, .purple]),
                    center: .center
                ),
                style: StrokeStyle(lineWidth: 8, lineCap: .round)
            )
            .frame(width: 100, height: 100)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(
                Animation.linear(duration: 1).repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}
