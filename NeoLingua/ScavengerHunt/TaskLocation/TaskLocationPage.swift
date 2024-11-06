import SwiftUI
import ActivityIndicatorView
import _PhotosUI_SwiftUI

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
            VStack(alignment: .center) {
                Text("Hint for the object").font(.subheadline).bold().multilineTextAlignment(.center)
                Text(location.photoClue).multilineTextAlignment(.center)
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
            if viewModel.selectedImage != nil {
                PrimaryButton(
                    title: "verify the image",
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
                        Button("back to map") {
                            router.navigateBack()
                        }
                    }
                }.presentationDetents([.fraction(0.50)])
            }
        }
    }
}

struct ImageValidationResultView: View {
    let validationResult: ImageValidationResult
    
    var body: some View {
        VStack {
            Text("Result")
                .font(.title)
                .bold()
            
            Image(systemName: validationResult.isMatching ? "checkmark.circle.fill" : "xmark.circle.fill")
                .resizable()
                .foregroundColor(validationResult.isMatching ? .green : .red)
                .frame(width: 50, height: 50)
            
            Text(validationResult.isMatching ? "The image matches the searched object!" : "The image does not match the searched object.")
                .font(.headline)
                .foregroundColor(validationResult.isMatching ? .green : .red)
                .multilineTextAlignment(.center)
                .padding(.bottom, Styleguide.Margin.small)
            
            VStack(alignment: .center, spacing: 10) {
                Text("Reason:")
                    .font(.subheadline)
                    .bold()
                
                Text(validationResult.reason)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                
                Text("Confidence Score:")
                    .font(.subheadline)
                    .bold()
                Text("\(validationResult.confidenceScore * 100, specifier: "%.1f")%")
                    .font(.body)
            }
            .padding()
        }
        .padding()
    }
}
