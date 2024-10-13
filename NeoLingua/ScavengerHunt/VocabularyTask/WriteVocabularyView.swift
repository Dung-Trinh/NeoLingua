import SwiftUI

struct WriteVocabularyView: View {
    @StateObject private var viewModel = WriteVocabularyViewModelImpl()
    
    var body: some View {
        VStack {
            Text(viewModel.exercise.question)
            TextField("Deine Antwort", text: $viewModel.userInputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .if(((viewModel.exercise as? SentenceBuildingExercise) != nil), transform: { view in
                    view.hidden()
                })
            
            if let sentenceExercise = viewModel.exercise as? SentenceBuildingExercise {
                SentenceBuildingView(
                    userAnswer: $viewModel.userInputText,
                    exercise: sentenceExercise
                )
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
