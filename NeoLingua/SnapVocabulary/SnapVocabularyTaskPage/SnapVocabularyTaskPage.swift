import SwiftUI
import ActivityIndicatorView

struct SnapVocabularyTaskPage<ViewModel>: View where ViewModel: SnapVocabularyTaskPageViewModel{
    @StateObject var viewModel: ViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    AsyncImageView(imageUrl: viewModel.sharedImageTask.imageUrl)
                        .frame(width: .infinity, height: 400)
                    InfoCardView(message: "Was sehen Sie auf dem Bild? Welche Vokabeln kannst du auf dem Bild erkennen? Beschreiben Sie das Bild!").padding(Styleguide.Margin.medium)
                    Text("There are \(viewModel.sharedImageTask.vocabulary.count) vocabulary to be found.").font(.headline).multilineTextAlignment(.leading)
                    TextField("In the picture I see ...", text: $viewModel.userInput, axis: .vertical)
                        .lineLimit(2...4)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)
                    
                    if let result = viewModel.result {
                        InspectImageResultView(
                            resultData: result,
                            searchedVocabulary: viewModel.sharedImageTask.vocabulary,
                            lastUserInput: viewModel.lastUserInput
                        )
                        if result.foundSearchedVocabulary && result.result == .correct {
                            Text("💎 Sie haben \(viewModel.finalPoints, specifier: "%.2f") Punkte erhalten 💎").font(.headline)
                        }
                    }
                    
                    if viewModel.showHintButton {
                        Button("Give me a hint") {
                            Task {
                                await viewModel.fetchHint()
                            }
                        }.buttonStyle(.bordered)
                    }
                    
                    if viewModel.hint != "" {
                        InfoCardView(
                            title: "Hinweis",
                            message: viewModel.hint,
                            type: .hint
                        )
                    }
                    
                    if viewModel.result?.result == .wrong || viewModel.result?.result == nil {
                        Button("Check Answer") {
                            Task {
                                await viewModel.validateUserInputWithImage()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            Spacer()
            if viewModel.isLoading {
                ActivityIndicatorView(isVisible: .constant(true), type: .scalingDots(count: 3, inset: 2))
                    .frame(width: 50.0, height: 50.0)
                    .foregroundColor(.red)
            }
            VStack {
                if viewModel.result?.foundSearchedVocabulary == true {
                    
                    PrimaryButton(
                        title: "Back to map",
                        color: .blue,
                        action: { isPresented = false }
                    )
                }
            }
        }
        .padding()
        .navigationTitle("SnapVocabulary")
        .navigationBarTitleDisplayMode(.inline)
    }
}

