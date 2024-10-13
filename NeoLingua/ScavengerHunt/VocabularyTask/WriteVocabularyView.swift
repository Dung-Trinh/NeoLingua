import SwiftUI

struct WriteVocabularyView: View {
    @StateObject private var viewModel = WriteVocabularyViewModelImpl()
    
    var body: some View {
        VStack {
            Text(viewModel.currentQuestion.text)
            TextField("Deine Antwort", text: $viewModel.userInputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
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
