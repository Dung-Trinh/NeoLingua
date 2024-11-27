import SwiftUI
import ActivityIndicatorView

struct ConversationSimulationPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: ConversationSimulationPageViewModelImpl
    
    var body: some View {
        VStack {
            if viewModel.conversationState == .contextDescription {
                if let roleOptionsResponse = viewModel.roleOptionsResponse {
                    InfoCardView(message: "Try to have a fluent and natural conversation. Integrate the task points into the dialog naturally.").padding(.bottom, Styleguide.Margin.large)
                    Text("Context").bold()
                    Text(roleOptionsResponse.contextDescription)
                    Button("Continue") {
                        viewModel.conversationState = .roleSelection
                        print(viewModel.conversationState)
                        print(viewModel.roleOptionsResponse)
                    }.buttonStyle(.bordered)
                }
            }
            if viewModel.conversationState == .roleSelection {
                VStack {
                    if let roleOptions = viewModel.roleOptionsResponse {
                        VStack {
                            Text("👤 Role Options").bold()
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
                                    Text("🗣️ Tasks").bold()
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
            
            if viewModel.conversationState == .conversation || viewModel.conversationState == .evaluation {
                if let selectedRole = viewModel.selectedRole {
                    VStack(alignment: .leading){
                        Text(.init("👤 **Role:** \(selectedRole.role)"))
                        Text("🗣️ Tasks").bold()
                        ForEach(selectedRole.tasks, id: \.self) { task in
                            VStack(alignment: .leading) {
                                HStack(alignment: .top) {
                                    Text("• \(task)")
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                
                if viewModel.audioPlayer.audioPlayer != nil {
                    AudioPlayerView(player: $viewModel.audioPlayer.audioPlayer).padding(.vertical, Styleguide.Margin.medium)
                }
                
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
                    .if(viewModel.conversationState == .evaluation, transform: { view in
                        view.disabled(true)
                    })
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 0.1).onEnded { _ in
                            viewModel.startRecording()
                        })
                case .text:
                    TextField("Eingabe", text: $viewModel.messageText)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)
                    Button("send Message") {
                        Task {
                            await viewModel.sendMessage(message: viewModel.messageText)
                        }
                    }.buttonStyle(.bordered)
                        .if(viewModel.conversationState == .evaluation, transform: { view in
                            view.disabled(true)
                        })
                }
            }
            Spacer()
            if viewModel.conversationState == .evaluation {
                PrimaryButton(
                    title: "Get evaluation",
                    color: .blue,
                    action: {
                        Task {
                            await viewModel.getConversationEvaluation()
                        }
                    })
                .sheet(isPresented: $viewModel.isEvaluationSheetPresented, onDismiss: {
                    viewModel.isResultSheetPresented = true
                }) {
                    if let evaluation = viewModel.conversationEvaluation {
                        VStack {
                            ConversationEvaluationView(evaluation: evaluation)
                            Spacer()
                            PrimaryButton(
                                title: "Schließen",
                                color: .blue,
                                action: {
                                    viewModel.isEvaluationSheetPresented = false
                                }
                            )
                        }
                        .padding()
                    }
                }
            }
            if viewModel.isLoading {
                ActivityIndicatorView(isVisible: .constant(true), type: .scalingDots(count: 3, inset: 2))
                    .frame(width: 50.0, height: 50.0)
                    .foregroundColor(.red)
            }
            
        }
        .padding()
        .sheet(isPresented: $viewModel.isResultSheetPresented) {
            if let taskPerformance = viewModel.taskPerformance{
                TaskCompleteSheetView(
                    taskPerformance: taskPerformance,
                    action: {
                        router.navigateBack()
                    }
                )
            }
        }
        .navigationTitle("Conversation Simulation")
        .navigationDestination(for: Route.self) { route in
            router.destination(for: route)
        }
    }
}
