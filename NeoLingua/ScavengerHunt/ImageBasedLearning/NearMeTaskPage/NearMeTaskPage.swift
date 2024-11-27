import SwiftUI
import ActivityIndicatorView

struct NearMeTaskPage: View {
    @StateObject var viewModel: NearMeTaskPageViewModelImpl
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    AsyncImageView(imageUrl: viewModel.sharedImageTask.imageUrl).frame(maxWidth: .infinity, maxHeight: 300)
                    InfoCardView(message: "What do you see in the picture? Which vocabulary can you identify from the picture? Describe the picture!").padding(.bottom, Styleguide.Margin.medium)
                    Text("There are \(viewModel.sharedImageTask.vocabulary.count) vocabulary to be found.").font(.headline).multilineTextAlignment(.leading)
                    TextField("In the picture I see ...", text: $viewModel.userInput, axis: .vertical)
                        .lineLimit(2...4)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)
                    
                    if let result = viewModel.result {
                        InspectImageResultView(resultData: result, searchedVocabulary: viewModel.sharedImageTask.vocabulary, lastUserInput: viewModel.lastUserInput)
                        if result.foundSearchedVocabulary {
                            Text("💎 You received  \(viewModel.finalPoints, specifier: "%.2f") points 💎").font(.headline)
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
                            title: "Hint",
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

struct InspectImageResultView: View {
    let resultData: InspectImageForVocabularyResult
    let searchedVocabulary: [String]
    let lastUserInput: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Validation Result")
                .fontWeight(.bold)
                .padding(.bottom, 10)
                .multilineTextAlignment(.center)
            VStack(alignment: .leading){
                if resultData.foundSearchedVocabulary {
                    Text("You found one of the vocabulary: ")
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                    Text(searchedVocabulary.joined(separator: ","))
                        .font(.body)
                        .multilineTextAlignment(.leading)
                } else {
                    Text("⚠️ Unfortunately there is non of the searched vocabulary in the text")
                }
            }
            
            HStack {
                Text("Result:")
                    .font(.headline)
                Text(resultData.result.text)
                    .font(.body)
                    .foregroundColor(resultData.result.color)
            }
            
            if let correctedText = resultData.correctedText {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Your Input:")
                        .font(.headline)
                        .foregroundColor(.red)
                    Text(lastUserInput)
                        .font(.body)
                        .foregroundColor(.gray)
                    Text("Corrected Text:")
                        .font(.headline)
                        .foregroundColor(.green)
                    Text(.init(correctedText))
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .padding(.top, 10)
            }
        }
        .frame(width: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }
}

