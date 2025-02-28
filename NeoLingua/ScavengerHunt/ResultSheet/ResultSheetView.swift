import SwiftUI
import Lottie

struct ResultSheetView<ViewModel>: View where ViewModel: ResultSheetViewModel {
    var viewModel: ViewModel
    private var isResultTrue: Bool {
        return viewModel.result == .correct
    }
    private var title: String {
        return isResultTrue ? "Richtig!" : "Leider falsch"
    }
    
    var body: some View {
        VStack {
            HStack {
                LottieView(animation: .named(isResultTrue ? "checkAnimation" : "crossmark"))
                    .playing()
                    .frame(width: 50, height: 50)
                Text(title)
                    .font(.title)
                    .padding()
                    .foregroundColor(viewModel.result == .correct ? Color.green : Color.red)
            }
            Text(viewModel.text)
                .padding()
            
            if viewModel.showDetailedFeedbackButton {
                SecondaryButton(title: "Detailliertes Feedback anfragen", color: .blue, action: {
                    viewModel.getDetailedFeedback()
                })
            }
            
            PrimaryButton(title: "Weiter", color: .blue, action: {
                viewModel.action()
            })
        }
        .frame(maxWidth: .infinity)
        .padding()
        .presentationCornerRadius(40)
    }
}
