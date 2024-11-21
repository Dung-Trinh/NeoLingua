import SwiftUI
import ActivityIndicatorView
import _PhotosUI_SwiftUI
import Lottie

struct TaskLocationPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: TaskLocationPageViewModelImpl
    
    var location: TaskLocation {
        return viewModel.taskLocation
    }
    
    var body: some View {
        VStack {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            Text(location.name).font(.title)
            Text("Tasks").font(.subheadline).bold()
            
            if let vocabularyTrainingPrompt =  location.taskPrompt.vocabularyTraining {
                VStack {
                    HStack {
                        Button("Vokabelübung starten") {
                            router.push(.learningTask(.vocabularyTrainingPage(prompt: location.taskPrompt.vocabularyTraining ?? "", isScavengerHuntMode: true)))
                        }.if(location.performance?.performance.vocabularyTraining?.isDone == true, transform: {
                            view in
                            view.disabled(true)
                        })
                        if location.performance?.performance.vocabularyTraining?.isDone == true {
                            Text("✅")
                        }
                    }
                    HStack {
                        Button("Hörverständnis Aufgaben starten") {
                            router.push(.learningTask(.listeningComprehensionPage(prompt: location.taskPrompt.listeningComprehension ?? "", isScavengerHuntMode: true)))
                        }.if(location.performance?.performance.listeningComprehension?.isDone == true, transform: {
                            view in
                            view.disabled(true)
                        })
                        if location.performance?.performance.listeningComprehension?.isDone == true {
                            Text("✅")
                        }
                    }
                    HStack {
                        Button("Gesprächssimulation starten") {
                            router.push(.learningTask(.conversationSimulationPage(prompt: location.taskPrompt.conversationSimulation ?? "", isScavengerHuntMode: true)))
                        }.if(location.performance?.performance.conversationSimulation?.isDone == true, transform: {
                            view in
                            view.disabled(true)
                        })
                        if location.performance?.performance.conversationSimulation?.isDone == true {
                            Text("✅")
                        }
                    }
                }
            }
            Spacer()
            if location.performance?.performance.isTaskDone() == true {
//            if true {
                VStack(alignment: .center, spacing: Styleguide.Margin.medium) {
                VStack {
                    InfoCardView(
                        title: "Hint for the object",
                        message: location.photoClue,
                        type: .hint
                    )
                }
                    HStack {
                        PhotosPicker(
                            selection: $viewModel.selectedPhotos,
                            maxSelectionCount: 1,
                            selectionBehavior: .ordered,
                            matching: .images
                        ) {
                            (Text(Image(systemName: "photo")) + Text("Select the image"))
                        }.onChange(of: viewModel.selectedPhotos) {
                            viewModel.convertDataToImage()
                        }
                        Text("or")
                        Button(action: {
                            viewModel.showCamera.toggle()
                        }, label: {
                            Label("Open Camera", systemImage: "camera.fill")
                        }).fullScreenCover(isPresented: $viewModel.showCamera) {
                            CameraView(selectedImage: $viewModel.selectedImage)
                                .background(.black)
                        }
                    }
            }
            if viewModel.selectedImage != nil {
                PrimaryButton(
                    title: "Verify the image",
                    color: .blue,
                    action: {
                        Task {
                            await viewModel.verifyImage()
                        }
                    }
                )
                if viewModel.isLoading {
                    ActivityIndicatorView(isVisible: .constant(true), type: .rotatingDots(count: 5))
                        .frame(width: 50.0, height: 50.0)
                        .foregroundColor(.red)
                }
            }
        }
        }
        .padding()
        .onAppear {
            Task {
                await viewModel.fetchTaskLocationState()
            }
        }
        .navigationDestination(for: Route.self) { route in
            router.destination(for: route)
        }
        .sheet(isPresented: $viewModel.isSheetPresented) {
            if let imageValidationResult = viewModel.imageValidationResult {
                VStack {
                    ImageValidationResultView(validationResult: imageValidationResult)
                    if(imageValidationResult.isMatching) {
                        Spacer()
                        PrimaryButton(
                            title: "Back to map",
                            color: .blue,
                            action: {
                                router.navigateBack()
                            }
                        )
                    }
                }
                .padding()
                .presentationDetents([.fraction(0.60)])
                .presentationCornerRadius(40)
            }
        }
    }
}

struct ImageValidationResultView: View {
    let validationResult: ImageValidationResult
    
    var body: some View {
        VStack {
            LottieView(animation: .named(validationResult.isMatching ? "firework": "crossmark"))
                .looping()
                .frame(width: .infinity, height: 200)
                .padding(-30)

                Text(validationResult.isMatching ? "The image matches the searched object!" : "The image does not match the searched object.")
                    .font(.title3)
                    .bold()
                    .foregroundColor(validationResult.isMatching ? .green : .red)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, Styleguide.Margin.small)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack() {
                    Text("🎯 Confidence Score:")
                        .font(.headline)
                        .bold()
                    Text("\(validationResult.confidenceScore * 100, specifier: "%.1f")%")
                        .font(.subheadline)
                }
                VStack(alignment: .leading) {
                    Text("🔎 Reason:")
                        .font(.headline)
                        .bold()
                        .multilineTextAlignment(.leading)
                    
                    Text(validationResult.reason)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding()
        }
    }
}
