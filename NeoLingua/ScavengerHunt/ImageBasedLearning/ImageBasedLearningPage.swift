import SwiftUI
import _PhotosUI_SwiftUI

struct ImageBasedLearningPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel = ImageBasedLearningPageViewModelImpl()
    
    var body: some View {
        VStack {
            ScrollView {
                if let selectedImage = viewModel.selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                    
                    if viewModel.state == .imageSelected {
                        VStack {
                            ForEach(TaskType.allCases, id: \.self) { taskType in
                                Toggle(isOn: Binding(
                                    get: { !viewModel.excludedTaskType.contains(taskType) },
                                    set: { isSelected in
                                        if isSelected {
                                            viewModel.excludedTaskType.removeAll { $0 == taskType }
                                        } else {
                                            viewModel.excludedTaskType.append(taskType)
                                        }
                                    }
                                )) {
                                    Text(taskType.rawValue)
                                }
                            }
                            
                            Button("analyze Image")
                            {
                                Task {
                                    await viewModel.analyzeImage()
                                }
                            }
                        }
                    }
                    
                    VStack {
                        if let imageBasedTask = viewModel.imageBasedTask {
                            Text(viewModel.imageBasedTask?.title ?? "").font(.title)
                            Text(viewModel.imageBasedTask?.description ?? "")
                            
                            if let vocabularyTraining = imageBasedTask.taskPrompt.vocabularyTraining {
                                PrimaryButton(
                                    title: "vocabularyTraining",
                                    color: viewModel.userPerformance?.vocabularyTraining != nil ? .green : .brown,
                                    action: {
                                        router.push( .imageBasedLearning(.vocabularyTrainingPage(prompt: vocabularyTraining)))
                                    }
                                )
                            }
                            
                            if let listeningComprehension = imageBasedTask.taskPrompt.listeningComprehension {
                                PrimaryButton(
                                    title: "listeningComprehension",
                                    color: viewModel.userPerformance?.listeningComprehension != nil ? .green : .brown,
                                    action: {
                                        router.push( .imageBasedLearning(.listeningComprehensionPage(prompt: listeningComprehension)))
                                    }
                                )
                            }
                            
                            if let conversationSimulation = imageBasedTask.taskPrompt.conversationSimulation {
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
                
                if viewModel.state == .initialState {
                    VStack {
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
                        
                        Text("OR").padding()
                        
                        Button(action: {
                            viewModel.openCamera()
                        }, label: {
                            Label("Open Camera", systemImage: "camera.fill")
                        }).fullScreenCover(isPresented: $viewModel.showCamera) {
                            CameraView(selectedImage: $viewModel.selectedImage)
                                .background(.black)
                        }
                    }
                }
                
            }
            Spacer()
            if viewModel.areAllTaskDone {
                VStack {
                    SecondaryButton(
                        title: "share your image with other",
                        color: .blue,
                        action: {
                            if let sharedImageForTask = viewModel.sharedImageForTask {
                                router.push(.shareImageForTaskPage(sharedImageForTask))
                            }
                            return nil
                        }
                    )
                    PrimaryButton(
                        title: "back to menu",
                        color: .blue,
                        action: {
                            router.navigateBack()
                        }
                    )
                }
            }
        }
        .onAppear {
            print("onAppear trigger")
            Task {
                await viewModel.fetchPerformance()
            }
        }
        .padding()
        .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
        .navigationDestination(for: Route.self) { route in
            router.destination(for: route)
        }
    }
}
