import SwiftUI

struct VocabularyTrainingPage: View {
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
                Text("multipleChoice")
                // TODO: create view for multipleChoice
//                if let exercise = viewModel.currentTask as? WriteWordExercise {
//                    
//                }
            }
            Button("check answer") {
                viewModel.checkAnswerTapped()
            }
        }
        .padding()
        .onAppear {
            Task {
                await viewModel.fetchVocabularyTraining()
            }
        }
        .sheet(isPresented: $viewModel.isSheetPresented) {
            if (viewModel.sheetViewModel != nil) {
                ResultSheetView(viewModel: viewModel.sheetViewModel!)
                    .presentationDetents([.fraction(0.25)])
            } else {
                EmptyView()
            }
        }
    }
}
