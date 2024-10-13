import SwiftUI

struct ResultSheetView : View {
    var viewModel: ResultSheetViewModel
    
    var title: String {
        switch viewModel.result {
        case .correct:
            return "Richtig!"
        case .incorrect:
            return "Leider Falsch"
        }
    }
    
    var body: some View {
        VStack {
            Text(title)
                .font(.title)
                .padding()
                .foregroundColor(viewModel.result == .correct ? Color.green : Color.red)
            
            Text(viewModel.text)
                .padding()
            
            Button("Weiter") {
                viewModel.action()
            }
        }.frame(maxWidth: .infinity)
    }
}
