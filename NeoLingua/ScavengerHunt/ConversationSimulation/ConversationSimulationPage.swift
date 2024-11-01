import SwiftUI
import ActivityIndicatorView

struct ConversationSimulationPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: ConversationSimulationPageViewModelImpl
    
    var body: some View {
        VStack {
            if viewModel.conversationState == .contextDescription {
                if let roleOptionsResponse = viewModel.roleOptionsResponse {
                    Text("ⓘ Note on the task").bold()
                    Text("Try to have a fluent and natural conversation. Integrate the task points into the dialog naturally.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, Styleguide.Margin.small)
                    
                    Text("Context").bold()
                    Text(roleOptionsResponse.contextDescription)
                    Button("continue") {
                        viewModel.conversationState = .roleSelection
                        print(viewModel.conversationState)
                        print(viewModel.roleOptionsResponse)
                    }
                }
            }
            if viewModel.conversationState == .roleSelection {
                VStack {
                    if let roleOptions = viewModel.roleOptionsResponse {
                        VStack {
                            Text("Role Options").bold()
                            Text("Choose one of the following roles and fulfill the tasks in the conversation👇🏻").multilineTextAlignment(.center)
                        }.padding(.vertical, Styleguide.Margin.small)
                        HStack(alignment: .top, spacing: Styleguide.Margin.small) {
                            ForEach(roleOptions.roleOptions) { role in
                                VStack(alignment: .center){
                                    Button(role.role) {
                                        Task {
                                            await viewModel.selectedRole(role: role)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 50)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    ForEach(role.tasks, id: \.self) { task in
                                        VStack(alignment: .leading) {
                                            HStack(alignment: .top) {
                                                Text("• \(task)")
                                                Spacer()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if viewModel.audioPlayer.audioPlayer != nil {
                AudioPlayerView(player: $viewModel.audioPlayer.audioPlayer)
            }
            
            if viewModel.conversationState == .conversation {
                Picker("Input Mode", selection: $viewModel.selectedMode) {
                    ForEach(ConversationInputMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                switch viewModel.selectedMode {
                case .speech:
                    Button {
                        viewModel.endRecording()
                    } label: {
                        if viewModel.isRecording {
                            ActivityIndicatorView(
                                isVisible: .constant(true), type: .gradient([.white, .red], lineWidth: 4)
                            )
                            .frame(width: 50.0, height: 50.0)
                            .foregroundColor(.red)
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
                case .text:
                    TextField("Eingabe", text: $viewModel.messageText)
                    Button("sendMessage") {
                        Task {
                            await viewModel.sendMessage(message: viewModel.messageText)
                        }
                    }
                }
            }
            if viewModel.conversationState == .evaluation {
                PrimaryButton(
                    title: "get evaluation",
                    color: .blue,
                    action: {
                        Task {
                            await viewModel.getConversationEvaluation()
                        }
                })
            }
        }
        .padding()
        .sheet(isPresented: $viewModel.isSheetPresented,
               onDismiss: {
            router.navigateBack()
        }) {
            if let evaluation = viewModel.conversationEvaluation {
                VStack {
                    ConversationEvaluationView(evaluation: evaluation)
                    Spacer()
                    PrimaryButton(
                        title: "back to task location",
                        color: .blue,
                        action: {
                            router.navigateBack()
                        }
                    )
                }.padding()
            }
        }
        .navigationDestination(for: Route.self) { route in
            router.destination(for: route)
        }
    }
}
