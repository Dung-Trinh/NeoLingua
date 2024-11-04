import SwiftUI
import ActivityIndicatorView
import Lottie

struct ShareImageForTaskPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: ShareImageForTaskPageViewModelImpl
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    Text("ⓘ Note").bold()
                    Text("Write down the vocabulary you see in the picture")
                    Text("e.g: vocabulary1, vocabulary2")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Image(uiImage: viewModel.sharedContentForTask.image)
                        .resizable()
                        .scaledToFit()
                    
                    TextField("vocabulary1, vocabulary2 ...", text: $viewModel.vocabulary)
                }
                
                Button("validate input") {
                    Task {
                        await viewModel.validateVocabulary()
                    }
                }
                
                Text("ⓘclick to approve the vocabulary")
                Text("✅ = is visible in the picture, ❌ = is not visible in the picture").font(.subheadline)
                    .foregroundColor(.gray)
                
                
                ForEach(viewModel.verifiedVocabular) { vocabulary in
                    if viewModel.approvedVocabulary.contains(vocabulary.name) == false {
                        VStack {
                            (Text(vocabulary.name) + Text(vocabulary.isInImage ? "✅" : "❌"))
                                .padding(Styleguide.Margin.extraSmall)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(.blue.opacity(0.5))
                                )
                                .onTapGesture {
                                    if vocabulary.isInImage {
                                        viewModel.addVocabulary(vocabulary: vocabulary.name)
                                    }
                                }
                            Text(.init(vocabulary.improvement ?? ""))
                        }
                    }
                }
                Text("ⓘ selected vocabulary for the image task").bold()
                HStack {
                    Text(viewModel.approvedVocabulary.description).padding(Styleguide.Margin.small)
                    Image(systemName: "trash.fill").onTapGesture {
                        viewModel.approvedVocabulary.removeAll()
                    }
                }
                Button("saveContent") {
                    Task {
                        await viewModel.saveContent()
                    }
                }
            }
            Spacer()
            if viewModel.isLoading {
                ActivityIndicatorView(isVisible: .constant(true), type: .scalingDots(count: 3, inset: 2))
                    .frame(width: 50.0, height: 50.0)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .sheet(isPresented: $viewModel.isSheetPresented) {
            VStack {
                Text("Thanks for sharing")
                LottieView(animation: .named("checkAnimation"))
                    .playing()
                    .frame(width: 50, height: 50)
                Button("back to menu") {
                    router.navigateToRoot()
                }
            }.presentationDetents([.fraction(0.25)])
        }
    }
}
