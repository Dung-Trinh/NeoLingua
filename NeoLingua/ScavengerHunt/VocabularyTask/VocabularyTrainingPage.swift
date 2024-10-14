import SwiftUI

struct VocabularyTrainingPage: View {
    @StateObject var viewModel = VocabularyTrainingPageViewModelImpl()
    
    var body: some View {
        VStack {            
            if let sentenceExercise = viewModel.exercise as? SentenceBuildingExercise {
                SentenceBuildingView(
                    userAnswer: $viewModel.userInputText,
                    exercise: sentenceExercise
                )
            } 
            if let writeExercise = viewModel.exercise as? WriteWordExercise {
                WriteVocabularyView(userInputText: $viewModel.userInputText, exercise: writeExercise)
            }
            Button("check answer") {
                viewModel.checkAnswerTapped()
            }
        }
        .padding()
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
