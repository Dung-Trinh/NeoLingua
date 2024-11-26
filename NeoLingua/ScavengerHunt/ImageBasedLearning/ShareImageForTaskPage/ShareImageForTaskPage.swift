import SwiftUI
import ActivityIndicatorView
import Lottie

struct ShareImageForTaskPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: ShareImageForTaskPageViewModelImpl
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 16){
                    VStack {
                        InfoCardView(message: "Write down the vocabulary you see in the picture. e.g: vocabulary1, vocabulary2").padding(.bottom, Styleguide.Margin.large)
                        
                        Image(uiImage: viewModel.sharedContentForTask.image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                        
                        Text("Enter your vocabulary for the image").font(.headline)
                        TextField("vocabulary1, vocabulary2 ...", text: $viewModel.vocabulary)
                            .textFieldStyle(.roundedBorder)
                        Button("Check answer") {
                            Task {
                                await viewModel.validateVocabulary()
                            }
                        }.buttonStyle(.borderedProminent)
                    }
                    
                    if viewModel.verifiedVocabular.count > 0 {
                        VStack{
                            Text("ⓘ Click to approve the vocabulary").font(.headline)
                            VStack {
                                Text("✅ = is visible in the picture")
                                Text("❌ = is not visible in the picture")
                            }
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            
                            ForEach(viewModel.verifiedVocabular) { vocabulary in
                                if viewModel.approvedVocabulary.contains(vocabulary.name) == false {
                                    HStack {
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
                                        Text(.init("(\(vocabulary.improvement ?? ""))"))
                                    }
                                }
                            }
                        }
                    }
                    
                    if viewModel.approvedVocabulary.count > 0 {
                        VStack {
                            Text("Your selection for the new SnapVocabulary task").bold()
                            HStack {
                                Text(viewModel.approvedVocabulary.description).padding(Styleguide.Margin.small)
                                Image(systemName: "trash.fill")
                                    .foregroundStyle(.red)
                                    .onTapGesture {
                                        viewModel.approvedVocabulary.removeAll()
                                    }
                            }
                        }
                    }
                }
            }
            Spacer()
            PrimaryButton(
                title: "Create new SnapVocabulary task",
                color: .blue,
                action: {
                    viewModel.saveContent()
                }
            )
            if viewModel.isLoading {
                ActivityIndicatorView(isVisible: .constant(true), type: .scalingDots(count: 3, inset: 2))
                    .frame(width: 50.0, height: 50.0)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .navigationTitle("Sharing content")
        .navigationBarTitleDisplayMode(.inline)
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
