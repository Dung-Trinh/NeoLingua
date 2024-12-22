import SwiftUI
import ActivityIndicatorView

struct ConversationSimulationPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: ConversationSimulationPageViewModelImpl
    
    var body: some View {
        VStack {
            ScrollView {
                if viewModel.conversationState == .contextDescription {
                    if let roleOptionsResponse = viewModel.roleOptionsResponse {
                        InfoCardView(message: "Versuchen Sie, ein flüssiges und natürliches Gespräch zu führen. Integrieren Sie die Aufgabenpunkte auf natürliche Weise in den Dialog.").padding(.bottom, Styleguide.Margin.large)
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
                            VStack {
                                Text("👤 Rollen").bold()
                                Text("Wählen Sie eine der folgenden Rollen und erfüllen Sie die Aufgaben im Gespräch👇🏻").multilineTextAlignment(.center)
                            }.padding(.vertical, Styleguide.Margin.small)
                            
                            HStack(alignment: .top, spacing: Styleguide.Margin.small) {
                                if let roleOptions = viewModel.roleOptionsResponse {
                                ForEach(roleOptions.roleOptions) { role in
                                    VStack(alignment: .center){
                                        Button(role.role) {
                                            Task {
                                                await viewModel.selectedRole(role: role)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        
                                        Text("🗣️ Aufgaben").bold()
                                        ForEach(role.tasks, id: \.self) { task in
                                            VStack(alignment: .leading) {
                                                HStack(alignment: .top) {
                                                    Text("• \(task)")
                                                    Spacer()
                                                }.padding(.bottom, Styleguide.Margin.medium)
                                                    .fixedSize(horizontal: false, vertical: true)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                if viewModel.conversationState == .conversation || viewModel.conversationState == .evaluation {
                    InfoCardView(message: "Wählen Sie zwischen Sprechen und Schreiben. Halten Sie das Mikrofonsymbol gedrückt und sprechen Sie dabei.").padding(.bottom, Styleguide.Margin.large)
                    if let selectedRole = viewModel.selectedRole {
                        VStack(alignment: .leading){
                            Text(.init("👤 **Rolle:** \(selectedRole.role)"))
                            Text("🗣️ Aufgaben").bold()
                            
                            ForEach(selectedRole.tasks, id: \.self) { task in
                                VStack(alignment: .leading) {
                                    HStack(alignment: .top) {
                                        Text("• \(task)")
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }.fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }.fixedSize(horizontal: false, vertical: true)
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
                            Text(viewModel.messageText).font(.subheadline).foregroundColor(.gray)
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
                            .lineLimit(2...4)
                            .autocorrectionDisabled()
                            .textFieldStyle(.roundedBorder)
                        
                    }
                    Button("end the conversation") {
                        Task {
                            await viewModel.sendMessage(message: "end the conversation")
                        }
                    }
                    .buttonStyle(.bordered)
                        .if(viewModel.conversationState == .evaluation || viewModel.isLoading, transform: { view in
                            view.disabled(true)
                        })
                    
                    Button("send message") {
                        Task {
                            await viewModel.sendMessage(message: viewModel.messageText)
                        }
                    }
                    .tint(.blue)
                    .buttonStyle(.bordered)
                        .if(viewModel.conversationState == .evaluation || viewModel.isLoading, transform: { view in
                            view.disabled(true)
                        })
                    
                }
                
                if let lastConversationResponse = viewModel.lastConversationResponse, lastConversationResponse.correctionOfUserInput != nil,lastConversationResponse.explanation != nil {
                    ExpandableTextView(userText: viewModel.lastUserMessage, correctedText: lastConversationResponse.correctionOfUserInput ?? "", explanation: lastConversationResponse.explanation ?? "")
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

struct ExpandableTextView: View {
    @State var isExpanded: Bool = false
    @State var userText: String
    @State var correctedText: String
    @State var explanation: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Attention ⚠️").font(.headline)
                Spacer()
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                    
                }
            }.padding()
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Your answer: \(userText)")
                        .foregroundColor(.red)
                    
                    Text("Corrected answer: \(correctedText)")
                        .foregroundColor(.green)
                    
                    Text("Explanation: \(explanation)")
                        .foregroundColor(.indigo)
                }
                .padding([.horizontal, .bottom])
                .cornerRadius(8)
            }
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
