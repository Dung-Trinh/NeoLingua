import SwiftUI

struct VocabularyTrainingPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: VocabularyTrainingPageViewModelImpl
    
    var body: some View {
        VStack {
            if viewModel.currentTask?.type == .sentenceAssembly {
                Text("sentenceAssembly")
                if let exercise = viewModel.currentTask as? SentenceBuildingExercise {
                    SentenceBuildingView(
                        userAnswer: $viewModel.userInputText,
                        exercise: exercise
                    )
                }
            }
            if viewModel.currentTask?.type == .fillInTheBlanks {
                Text("fillInTheBlanks")
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
                    .presentationDetents([.fraction(0.25)])
            } else {
                EmptyView()
            }
        }
    }
}
