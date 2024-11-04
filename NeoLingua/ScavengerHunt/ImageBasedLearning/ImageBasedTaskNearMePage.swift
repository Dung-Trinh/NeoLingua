import SwiftUI
import Firebase

struct ImageBasedTaskNearMePage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: ImageBasedTaskNearMePageViewModelImpl

    var body: some View {
        VStack {
            if viewModel.sharedImageTask == nil {
                List(viewModel.allTasks) { task in
                    SharedImageTaskRowView(task: task).onTapGesture {
                        viewModel.sharedImageTask = task
                    }
                }
            }
            if viewModel.sharedImageTask != nil {
                taskView
            }
            if viewModel.result?.result != .wrong &&  viewModel.result?.foundSearchedVocabulary == true {
                PrimaryButton(
                    title: "back to overview",
                    color: .blue,
                    action: {  router.navigateBack() }
                )
            }
        }
        .onAppear{
            viewModel.fetchImageBasedTaskNearMe()
        }
    }
    
    @ViewBuilder
    private var taskView: some View {
        ScrollView {
            VStack {
                Text("ⓘWhat do you see in the picture? Which vocabulary can you identify from the picture").bold()
                Text("describe the picture")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                AsyncImageView(imageUrl: viewModel.sharedImageTask?.imageUrl ?? "")
                TextField("In the picture I see ...", text: $viewModel.userInput)
                    .lineLimit(2...4)
                    .textFieldStyle(.roundedBorder)
                if let result = viewModel.result {
                    InspectImageResultView(resultData: result, searchedVocabulary: viewModel.sharedImageTask?.vocabulary ?? [], lastUserInput: viewModel.lastUserInput)
                }
                
                if viewModel.showHintButton {
                    Button("give me a hint") {
                        Task {
                            await viewModel.fetchHint()
                        }
                    }
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
                    }
                }
                
            }.padding()
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
                    Text("⚠️unfortunately there is no vocabulary in the text").font(.headline)
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

struct SharedImageTaskRowView: View {
    let task: SnapVocabularyTask
    
    var body: some View {
        HStack(alignment: .center) {
            AsyncImageView(imageUrl: task.imageUrl).frame(height: 200)
        }
    }
}
