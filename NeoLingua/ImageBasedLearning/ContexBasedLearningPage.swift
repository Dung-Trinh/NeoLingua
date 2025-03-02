import SwiftUI
import _PhotosUI_SwiftUI

struct ContexBasedLearningPage<ViewModel>: View where ViewModel: ContextBasedLearningPageViewModel {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: ViewModel
    
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
                            Button(action: {
                                viewModel.navigateTo(.contextBasedLearning(.vocabularyTrainingPage(prompt: vocabularyTraining)))
                            }, label: {
                                HStack{
                                    Text(TaskType.vocabularyTraining.localizedText)
                                    if viewModel.userPerformance?.vocabularyTraining != nil {
                                        Text("✅")
                                    }
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.accentColor)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.accentColor, lineWidth: 1)
                                )
                            })
                            .if(viewModel.userPerformance?.vocabularyTraining != nil, transform: {
                                view in
                                view.disabled(true)
                            })
                        }
                        
                        if let listeningComprehension = imageBasedTask.taskPrompt.listeningComprehension {
                            Button(action: {
                                viewModel.navigateTo(.contextBasedLearning(.listeningComprehensionPage(prompt: listeningComprehension)))
                            }, label: {
                                HStack{
                                    Text(TaskType.listeningComprehension.localizedText)
                                    if viewModel.userPerformance?.listeningComprehension != nil {
                                        Text("✅")
                                    }
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.accentColor)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.accentColor, lineWidth: 1)
                                )
                            })
                            .if(viewModel.userPerformance?.listeningComprehension != nil, transform: {
                                view in
                                view.disabled(true)
                            })
                        }
                        
                        if let conversationSimulation = imageBasedTask.taskPrompt.conversationSimulation {
                            Button(action: {
                                viewModel.navigateTo(.contextBasedLearning(.conversationSimulationPage(prompt: conversationSimulation)))
                            }, label: {
                                HStack{
                                    Text(TaskType.conversationSimulation.localizedText)
                                    if viewModel.userPerformance?.conversationSimulation != nil {
                                        Text("✅")
                                    }
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.accentColor)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.accentColor, lineWidth: 1)
                                )
                            })
                            .if(viewModel.userPerformance?.conversationSimulation != nil, transform: {
                                view in
                                view.disabled(true)
                            })
                        }
                    }
                }
                if viewModel.state == .initialState {
                    Text("Erstellung von Lerninhalten")
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.leading)
                    Text("Wie möchtest du den Inhalt deiner Übungen bestimmen?")
                        .multilineTextAlignment(.center)
                    
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
                                viewModel.shouldShowPromptInput.toggle()
                            }
                        }, label: {
                            Text("Beschreibe deine Aufgabe 📝")
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(viewModel.shouldShowPromptInput ? Color.green : .accentColor)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(viewModel.shouldShowPromptInput ? Color.green : Color.accentColor, lineWidth: 1)
                                )
                        })
                        Spacer(minLength: 50)
                        Image("guyTalkingToBot").resizable().frame(height: 300).scaledToFit()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                    if viewModel.shouldShowPromptInput {
                        VStack {
                            Text("Beispiel: Erstelle mir Aufgaben über das Thema Umweltschutz.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            TextField("Prompt...", text: $viewModel.promptText, axis: .vertical)
                                .lineLimit(2...)
                                .autocorrectionDisabled()
                                .textFieldStyle(.roundedBorder)
                            taskSelection
                            Button("Aufgabe erstellen") {
                                Task {
                                    await viewModel.createTasksWithPrompt()
                                }
                            }.buttonStyle(.bordered)
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
                                    viewModel.navigateTo(.shareImageForTaskPage(sharedImageForTask))
                                }
                                return nil
                            }
                        )
                    }
                    PrimaryButton(
                        title: "Back to menu",
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
        .navigationTitle("Contex-based-tasks")
        .navigationBarTitleDisplayMode(.inline)
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
