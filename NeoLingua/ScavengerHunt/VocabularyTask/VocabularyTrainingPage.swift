import SwiftUI
import ProgressIndicatorView
struct VocabularyTrainingPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: VocabularyTrainingPageViewModelImpl
    
    var body: some View {
        VStack {
            Text("Fortschritt zur Erfüllung der Aufgabe")
            ProgressIndicatorView(
                isVisible: $viewModel.showProgressIndicator,
                type: .dashBar(
                    progress: $viewModel.progress,
                    numberOfItems: viewModel.numberOfTasks,
                    backgroundColor: .gray.opacity(0.25)
                )
            )
            .frame(height: 12.0)
            .foregroundColor(.red)
            .padding(.bottom, Styleguide.Margin.extraLarge)
            
            if viewModel.currentTask?.type == .sentenceAssembly {
                if let exercise = viewModel.currentTask as? SentenceBuildingExercise {
                    SentenceBuildingView(
                        userAnswer: $viewModel.userInputText,
                        exercise: exercise
                    )
                }
            }
            if viewModel.currentTask?.type == .fillInTheBlanks {
                if let exercise = viewModel.currentTask as? WriteWordExercise {
                    WriteVocabularyView(
                        userInputText: $viewModel.userInputText,
                        exercise: exercise
                    )
                }
            }
            if viewModel.currentTask?.type == .multipleChoice {
                if let exercise = viewModel.currentTask as? ChooseWordExercise {
                    MultipleChoiceView(
                        userInputText: $viewModel.userInputText,
                        exercise: exercise
                    ) {
                        viewModel.checkAnswerTapped()
                    }
                }
            }
            Button("check answer") {
                viewModel.checkAnswerTapped()
            }.if(
                viewModel.isCheckAnswerButtonHidden,
                transform: { view in
                    view.hidden()
                })
            
            Spacer()
            if(viewModel.showResult) {
                PrimaryButton(
                    title: "back to tasks",
                    color: .blue,
                    action: {
                        router.navigateBack()
                    }
                )
            }
        }
        .padding()
        .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
        .onAppear {
            Task {
                await viewModel.fetchVocabularyTraining()
            }
        }
        .sheet(isPresented: $viewModel.isSheetPresented) {
            if viewModel.showResult {
                VStack {
                    Text("ALL DONE")
                    Button("back to tasks") {
                        router.navigateBack()
                    }
                }
            }
            if (viewModel.sheetViewModel != nil) {
                ResultSheetView(viewModel: viewModel.sheetViewModel!)
                    .presentationDetents([.fraction(0.40)])
                    .sheet(isPresented: $viewModel.isExplanationSheetPresented, content: {
                        VStack {
                            Text("Nutzereingabe:")
                            Text(viewModel.userInputText).padding(.bottom, Styleguide.Margin.small)
                            Text("Erklärung des Fehlers").bold()
                            Text(.init(viewModel.explanationText))
                        }.padding()
                    })
            } else {
                EmptyView()
            }
        }
    }
}
