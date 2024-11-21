import SwiftUI
import ProgressIndicatorView
import Lottie

struct VocabularyTrainingPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: VocabularyTrainingPageViewModelImpl
    
    var body: some View {
        VStack {
            ProgressIndicatorView(
                isVisible: $viewModel.showProgressIndicator,
                type: .dashBar(
                    progress: $viewModel.progress,
                    numberOfItems: viewModel.numberOfTasks,
                    backgroundColor: .gray.opacity(0.25)
                )
            )
            .frame(height: 12.0)
            .foregroundColor(.blue)
            .padding(.bottom, Styleguide.Margin.extraLarge)
            
            if viewModel.currentTask?.type == .sentenceAssembly {
                if let exercise = viewModel.currentTask as? SentenceBuildingExercise {
                    SentenceBuildingView(
                        userAnswer: $viewModel.userInputText,
                        exercise: exercise
                    )
                }
            }
            if viewModel.currentTask?.type == .fillInTheBlanks {
                if let exercise = viewModel.currentTask as? WriteWordExercise {
                    WriteVocabularyView(
                        userInputText: $viewModel.userInputText,
                        exercise: exercise
                    )
                }
            }
            if viewModel.currentTask?.type == .multipleChoice {
                if let exercise = viewModel.currentTask as? ChooseWordExercise {
                    MultipleChoiceView(
                        userInputText: $viewModel.userInputText,
                        exercise: exercise
                    ) {
                        viewModel.checkAnswerTapped()
                    }
                }
            }
            Button("check answer") {
                viewModel.checkAnswerTapped()
            }
            .buttonStyle(.borderedProminent)
            .if(
                viewModel.isCheckAnswerButtonHidden,
                transform: { view in
                    view.hidden()
                }
            )
            
            Spacer()
            if(viewModel.showResult) {
                PrimaryButton(
                    title: "back to tasks",
                    color: .blue,
                    action: {
                        router.navigateBack()
                    }
                )
            }
        }
        .padding()
        .navigationTitle("Vocabulary Training")
        .navigationBarTitleDisplayMode(.inline)
        .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
        .onAppear {
            Task {
                await viewModel.fetchVocabularyTraining()
            }
        }
        .sheet(isPresented: $viewModel.isSheetPresented) {
            if let taskPerformance = viewModel.taskPerformance, viewModel.showResult {
                TaskCompleteSheetView(
                    taskPerformance: taskPerformance,
                    action: {
                        router.navigateBack()
                    }
                )
            }
            if (viewModel.sheetViewModel != nil) {
                ResultSheetView(viewModel: viewModel.sheetViewModel!)
                    .presentationDetents([.fraction(0.40)])
                    .sheet(isPresented: $viewModel.isExplanationSheetPresented, content: {
                        VStack {
                            Text("Nutzereingabe:")
                            Text(viewModel.userInputText).padding(.bottom, Styleguide.Margin.small)
                            Text("Erklärung des Fehlers").bold()
                            Text(.init(viewModel.explanationText))
                        }.padding()
                    })
            } else {
                EmptyView()
            }
        }
    }
}

struct InfoCardView: View {
    enum InfomationType {
        case hint
        case info
    }
    
    var title: String?
    var message: String
    var type: InfomationType
    
    var foregroundColor: Color {
        switch type {
            case .info: Color.blue
            case .hint: Color.orange
        }
    }
    
    var backgroundColor: Color {
        switch type {
            case .info: foregroundColor.opacity(0.1)
            case .hint: foregroundColor.opacity(0.3)
        }
    }
    
    var iconName: String {
        switch type {
            case .info: "info.circle"
            case .hint: "magnifyingglass.circle"
        }
    }
    
    init(title: String? = nil, message: String, type: InfomationType = .info) {
        self.title = title
        self.message = message
        self.type = type
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: Styleguide.Margin.small) {
            ZStack {
                Circle()
                    .fill(foregroundColor)
                    .frame(width: 25, height: 25)
                
                Image(systemName: iconName)
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .bold))
            }
            
            VStack(alignment: .leading) {
                if let title = title {
                    Text(title)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                }
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
    }
}

struct TaskCompleteSheetView: View {
    let taskPerformance: TaskPerformancetParameter
    let action: () -> Void?
    
    var body: some View {
        VStack {
            LottieView(animation: .named("firework"))
                .looping()
                .frame(width: 200, height: 200)
                .padding(-30)
            Text("Übung absolviert!").font(.title).bold().foregroundColor(.green)
            HStack {
                VStack {
                    Text("💎 Punkte")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Text("\(taskPerformance.finalPoints ?? 0, specifier: "%.2f") ")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                VStack {
                    Text("🎯 Genauigkeit")
                        .font(.headline)
                        .foregroundColor(.purple)
                    Text("\(Int(taskPerformance.result * 100)) %").font(.subheadline)
                        .foregroundColor(.purple)
                        .bold()
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }

            Spacer()
            PrimaryButton(
                title: "Zurück zur Übersicht",
                color: .blue,
                action: {
                    action()
                }
            )
        }
        .presentationDetents([.fraction(0.5)])
        .presentationCornerRadius(40)
        .padding()
    }
}
