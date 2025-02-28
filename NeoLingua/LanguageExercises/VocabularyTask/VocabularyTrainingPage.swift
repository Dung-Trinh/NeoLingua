import SwiftUI
import ProgressIndicatorView
import Lottie

struct VocabularyTrainingPage<ViewModel>: View where ViewModel: VocabularyTrainingPageViewModel {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            ProgressIndicatorView(
                isVisible: $viewModel.showProgressIndicator,
                type: .dashBar(
                    progress: $viewModel.progress,
                    numberOfItems: viewModel.numberOfTasks,
                    backgroundColor: .gray.opacity(0.25)
                )
            )
            .frame(height: 12.0)
            .foregroundColor(.blue)
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
            }
            .buttonStyle(.borderedProminent)
            .if(
                viewModel.isCheckAnswerButtonHidden,
                transform: { view in
                    view.hidden()
                }
            )
            
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
        .navigationTitle("Vocabulary Training")
        .navigationBarTitleDisplayMode(.inline)
        .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
        .onAppear {
            Task {
                await viewModel.fetchVocabularyTraining()
            }
        }
        .sheet(isPresented: $viewModel.isSheetPresented) {
            if let taskPerformance = viewModel.taskPerformance, viewModel.showResult {
                TaskCompleteSheetView(
                    taskPerformance: taskPerformance,
                    action: {
                        router.navigateBack()
                    }
                )
            }
            if (viewModel.sheetViewModel != nil) {
                ResultSheetView(viewModel: viewModel.sheetViewModel!)
                    .presentationDetents([.fraction(0.40)])
                    .sheet(isPresented: $viewModel.isExplanationSheetPresented, content: {
                        ScrollView {
                            VStack {
                                Text("Nutzereingabe:").font(.headline).bold().foregroundColor(.red)
                                Text(viewModel.userInputText).padding(.bottom, Styleguide.Margin.medium)
                                Text("Erklärung des Fehlers").bold().foregroundColor(.indigo)
                                Text(.init(viewModel.explanationText)).padding(.bottom, Styleguide.Margin.extraLarge)
                                Image("explanationImage").resizable().scaledToFit().frame(height: 200)
                            }
                            .padding()
                        }
                    })
            } else {
                EmptyView()
            }
        }
    }
}
