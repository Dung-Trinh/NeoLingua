import SwiftUI

struct TaskLocationPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: TaskLocationPageViewModelImpl
    
    var location: TaskLocation {
        return viewModel.taskLocation
    }
    
    var body: some View {
        VStack {
            Text(location.name)
            Text(location.type)
            
            if let vocabularyTrainingPrompt =  location.taskPrompt.vocabularyTraining {
                VStack {
                    Button("Vokabelübung starten") {
                        router.push(.learningTask(.vocabularyTrainingPage(prompt: location.taskPrompt.vocabularyTraining ?? "")))
                    }
                    
                    Button("Hörverständnis Aufgaben starten") {
                        router.push(.learningTask(.listeningComprehensionPage(prompt: location.taskPrompt.listeningComprehension ?? "")))
                    }
                    
                    Button("Gesprächssimulation starten") {
                        router.push(.learningTask(.conversationSimulationPage(prompt: location.taskPrompt.conversationSimulation ?? "")))
                    }
                    
                    Button("Schreibaufgabe starten") {
//                        router.push(.learningTask(.writingTaskPage))
                    }
                }
            }
            
            Text(location.photoClue)
            Text(location.photoObject)
        }.navigationDestination(for: Route.self) { route in
            router.destination(for: route)
        }
    }
}
