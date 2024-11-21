import SwiftUI
import ActivityIndicatorView

struct NearMeTaskPage: View {
    @StateObject var viewModel: NearMeTaskPageViewModelImpl
    @Binding var isPresented: Bool
    
    var body: some View {
        ScrollView {
            VStack {
                AsyncImageView(imageUrl: viewModel.sharedImageTask.imageUrl).frame(maxWidth: .infinity, maxHeight: 300)
                InfoCardView(message: "What do you see in the picture? Which vocabulary can you identify from the picture? Describe the picture!").padding(.bottom, Styleguide.Margin.medium)
                    TextField("In the picture I see ...", text: $viewModel.userInput, axis: .vertical)
                        .lineLimit(2...4)
                        .textFieldStyle(.roundedBorder)
                
                if let result = viewModel.result {
                    InspectImageResultView(resultData: result, searchedVocabulary: viewModel.sharedImageTask.vocabulary, lastUserInput: viewModel.lastUserInput)
                    if result.foundSearchedVocabulary {
                        Text("your points: \(viewModel.finalPoints)")
                    }
                }
                
                if viewModel.showHintButton {
                    Button("give me a hint") {
                        Task {
                            await viewModel.fetchHint()
                        }
                    }.buttonStyle(.bordered)
                }
                
                if viewModel.hint != "" {
                    Text("hint:").bold()
                    Text(viewModel.hint)
                }
                
                if viewModel.result?.result == .wrong || viewModel.result?.result == nil {
                    Button("validate") {
                        Task {
                            await viewModel.validateUserInputWithImage()
                        }
                    }.buttonStyle(.borderedProminent)
                }
                Spacer()
                if viewModel.isLoading {
                    ActivityIndicatorView(isVisible: .constant(true), type: .scalingDots(count: 3, inset: 2))
                        .frame(width: 50.0, height: 50.0)
                        .foregroundColor(.red)
                }
                VStack {
                    if  viewModel.result?.foundSearchedVocabulary == true {
                        PrimaryButton(
                            title: "back to overview",
                            color: .blue,
                            action: { isPresented = false }
                        )
                    }
                }
                
            }
            .padding()
            .navigationTitle("SnapVocabulary")
        }
    }
}

struct InspectImageResultView: View {
    let resultData: InspectImageForVocabularyResult
    let searchedVocabulary: [String]
    let lastUserInput: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Validation Result")
                .fontWeight(.bold)
                .padding(.bottom, 10)
            
            VStack {
                if resultData.foundSearchedVocabulary {
                    Text("you found one of the vocabulary: ")
                        .font(.headline)
                    Text(searchedVocabulary.joined(separator: ","))
                        .font(.body)
                } else {
                    Text("⚠️unfortunately there is non of the searched vocabulary in the text").font(.headline)
                }
            }
            
            HStack {
                Text("Result:")
                    .font(.headline)
                Text(resultData.result.rawValue)
                    .font(.body)
                    .foregroundColor(colorForStatus(resultData.result))
            }
            
            if let correctedText = resultData.correctedText {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Your Input:")
                        .font(.headline)
                    Text(lastUserInput)
                        .font(.body)
                        .foregroundColor(.gray)
                    Text("Corrected Text:")
                        .font(.headline)
                    Text(.init(correctedText))
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .padding(.top, 10)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
        .padding()
    }
    
    func colorForStatus(_ status: EvaluationStatus) -> Color {
        switch status {
        case .correct:
            return .green
        case .wrong:
            return .red
        case .almostCorrect:
            return .orange
        }
    }
}

