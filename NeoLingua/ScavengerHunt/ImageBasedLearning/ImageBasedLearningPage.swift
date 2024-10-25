import SwiftUI
import _PhotosUI_SwiftUI

struct ImageBasedLearningPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel = ImageBasedLearningPageViewModelImpl()
    
    var body: some View {
        VStack {
            if let selectedImage = viewModel.selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
            }
            PhotosPicker(
                selection: $viewModel.selectedPhotos,
                maxSelectionCount: 1,
                selectionBehavior: .ordered,
                matching: .images
            ) {
                Label("Select a image", systemImage: "photo")
            }.onChange(of: viewModel.selectedPhotos) {
                viewModel.convertDataToImage()
                
            }
            
            Button("sendRequest") {
                Task {
                    await viewModel.sendRequest()
                }
            }
            Button("upload") {
                Task {
                    await viewModel.uploadImage()
                }
            }
            Button("requestVisionAPI3") {
                Task {
                    do {
                        await try viewModel.requestVisionAPI3()
                    } catch {
                        print("upload error: ", error.localizedDescription)
                    }
                }
            }
            
            VStack {
                if let taskPrompt = viewModel.imageBasedTask?.taskPrompt {
                    if let vocabularyTraining = taskPrompt.vocabularyTraining {
                        PrimaryButton(
                            title: "vocabularyTraining",
                            color: viewModel.userPerformance?.vocabularyTraining != nil ? .green : .brown,
                            action: {
                                router.push( .imageBasedLearning(.vocabularyTrainingPage(prompt: vocabularyTraining)))
                            }
                        )
                    }
                    
                    if let listeningComprehension = taskPrompt.listeningComprehension {
                        PrimaryButton(
                            title: "listeningComprehension",
                            color: viewModel.userPerformance?.listeningComprehension != nil ? .green : .brown,
                            action: {
                                router.push( .imageBasedLearning(.listeningComprehensionPage(prompt: listeningComprehension)))
                            }
                        )
                    }

                    if let conversationSimulation = taskPrompt.conversationSimulation {
                        PrimaryButton(
                            title: "conversationSimulation",
                            color: viewModel.userPerformance?.conversationSimulation != nil ? .green : .brown,
                            action: {
                                router.push(.imageBasedLearning(.conversationSimulationPage(prompt: conversationSimulation)))
                            }
                        )
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.isSheetPresented) {
            VStack {
                Text("Exercise done")
                Button("back to menu") {
                    router.navigateBack()
                }
            }.presentationDetents([.fraction(0.25)])
        }
        .onAppear {
            print("onAppear trigger")
            Task {
                await viewModel.fetchPerformance()
            }
        }
        .padding()
        .navigationDestination(for: Route.self) { route in
                router.destination(for: route)
        }
    }
}
