import SwiftUI
import AVFAudio
import SwiftOpenAI

struct ListeningComprehensionPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: ListeningComprehensionPageViewModelImpl
    
    var body: some View {
        ScrollView {
            VStack {
                Text("ⓘ Task definition").bold()
                VStack(alignment: .leading) {
                    Text("Listen to the text carefully.Respond to the following questions when you're ready.").font(.subheadline)
                        .foregroundColor(.gray).padding(.bottom, Styleguide.Margin.small)
                    
                    AudioPlayerView(player: $viewModel.audioPlayer.audioPlayer).padding(.vertical, Styleguide.Margin.small)
            
                    if let exercise = viewModel.exercise {
                        VStack(alignment: .center) {
                            Text("Task questions").font(.title2)
                            ForEach(exercise.listeningQuestions.indices, id: \.self) { index in
                                VStack(alignment: .leading, spacing: Styleguide.Margin.small) {
                                    Text(exercise.listeningQuestions[index].question)
                                        .font(.subheadline)
                                    if viewModel.answers.count > index {
                                        HStack {
                                            TextField("Your answer...", text: $viewModel.answers[index])
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                            
                                            if viewModel.evaluatedQuestion.count > 0 {
                                                Text(viewModel.evaluatedQuestion[index].isAnswerRight ? "✅" : "❌")
                                            }
                                        }.if(viewModel.evaluatedQuestion.count > 0, transform: { view in
                                            view.disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                                        })
                                    }
                                    
                                }.padding(.vertical, 10)
                            }
                        }
                    }
                    
                    if let evaluation = viewModel.evaluation {
                        VStack(spacing: Styleguide.Margin.small) {
                            ListeningTaskEvaluationView(evaluation: evaluation)
                            PrimaryButton(
                                title: "back to tasks",
                                color: .blue,
                                action: {
                                    router.navigateBack()
                                })
                        }
                    }
                }
                
                Button("Evaluate Questions") {
                    Task {
                        await viewModel.evaluateQuestions()
                    }
                }.if(viewModel.evaluation != nil,
                     transform: { view in
                    view.hidden()
                })
            }
            .padding()
            .navigationTitle("Listening comprehension")
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
