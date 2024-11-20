import SwiftUI
import _PhotosUI_SwiftUI

struct ImageBasedLearningPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel = ImageBasedLearningPageViewModelImpl()
    @State var shouldShowPromptInput = false
    
    var body: some View {
        VStack {
            ScrollView {
                if let selectedImage = viewModel.selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 400)
                    if viewModel.state == .imageSelected {
                        VStack {
                            taskSelection.padding()
                            
                            Button("Bild analysieren & Aufgaben erstellen"){
                                Task {
                                    await viewModel.analyzeImage()
                                }
                            }.buttonStyle(.borderedProminent)
                        }
                    }
                }
                if let imageBasedTask = viewModel.imageBasedTask {
                    VStack {
                        
                        Text(viewModel.imageBasedTask?.title ?? "").font(.title)
                        Text(viewModel.imageBasedTask?.description ?? "")
                        
                        if let vocabularyTraining = imageBasedTask.taskPrompt.vocabularyTraining {
                            PrimaryButton(
                                title: TaskType.vocabularyTraining.localizedText,
                                color: viewModel.userPerformance?.vocabularyTraining != nil ? .green : .brown,
                                action: {
                                    router.push( .imageBasedLearning(.vocabularyTrainingPage(prompt: vocabularyTraining)))
                                }
                            )
                        }
                        
                        if let listeningComprehension = imageBasedTask.taskPrompt.listeningComprehension {
                            PrimaryButton(
                                title: TaskType.listeningComprehension.localizedText,
                                color: viewModel.userPerformance?.listeningComprehension != nil ? .green : .brown,
                                action: {
                                    router.push( .imageBasedLearning(.listeningComprehensionPage(prompt: listeningComprehension)))
                                }
                            )
                        }
                        
                        if let conversationSimulation = imageBasedTask.taskPrompt.conversationSimulation {
                            PrimaryButton(
                                title: TaskType.conversationSimulation.localizedText,
                                color: viewModel.userPerformance?.conversationSimulation != nil ? .green : .brown,
                                action: {
                                    router.push(.imageBasedLearning(.conversationSimulationPage(prompt: conversationSimulation)))
                                }
                            )
                        }
                    }
                }
                if viewModel.state == .initialState {
                    Text("Erstellung von Lerninhalten")
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.leading)
                    Text("Wie möchtest du den Inhalt deiner Übungen bestimmen?")
                        .font(.headline).multilineTextAlignment(.center)
                    
                    VStack(spacing: Styleguide.Margin.medium) {
                        PhotosPicker(
                            selection: $viewModel.selectedPhotos,
                            maxSelectionCount: 1,
                            selectionBehavior: .ordered,
                            matching: .images
                        ) {
                            
                            Text("Wähle ein Bild aus deinem Album aus 🖼️")
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.accentColor)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.accentColor, lineWidth: 1)
                                )
                        }.onChange(of: viewModel.selectedPhotos) {
                            viewModel.convertDataToImage()
                        }
                                    
                        
                        
                        Button(action: {
                            viewModel.openCamera()
                        }, label: {
                            Text("Schieße ein Foto 📸")
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.accentColor)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.accentColor, lineWidth: 1)
                                )
                        }).fullScreenCover(isPresented: $viewModel.showCamera) {
                            CameraView(selectedImage: $viewModel.selectedImage)
                                .background(.black)
                        }
                        
                        Button(action: {
                            withAnimation {
                                shouldShowPromptInput.toggle()
                            }
                        }, label: {
                            Text("Beschreibe deine Aufgabe 📝")
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(shouldShowPromptInput ? Color.green : .accentColor)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(shouldShowPromptInput ? Color.green : Color.accentColor, lineWidth: 1)
                                )
                        })
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                    if shouldShowPromptInput {
                        VStack {
                            Text("Beispiel: Erstelle mir Aufgaben über das Thema Umweltschutz.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            TextField("Prompt...", text: $viewModel.promptText, axis: .vertical)
                                .lineLimit(2...)
                                .textFieldStyle(.roundedBorder)
                            taskSelection
                            Button("Aufgabe erstellen") {
                                Task {
                                    await viewModel.createTasksWithPrompt()
                                }
                            }.buttonStyle(.borderedProminent)
                        }.padding(.horizontal, 8)
                    }
                }
                
            }
            Spacer()
            if viewModel.areAllTaskDone {
                VStack {
                    if viewModel.selectedImage != nil {
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
                    }
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
    
    @ViewBuilder
    private var taskSelection: some View {
        VStack {
            Text("Welche Aufgabentypen möchtest du generieren?")
                .font(.headline).multilineTextAlignment(.center)
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
                    Text(taskType.localizedText)
                }
            }
        }
    }
}
