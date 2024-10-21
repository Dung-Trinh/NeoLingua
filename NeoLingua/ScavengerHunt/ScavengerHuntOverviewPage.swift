import SwiftUI

struct ScavengerHuntOverviewPage: View {
    @EnvironmentObject private var router: Router
    @StateObject private var viewModel = ScavengerHuntOverviewPageViewModelImpl()
    
    var body: some View {
        VStack {
            if let scavengerHunt = viewModel.currentScavengerHunt {
                Button("Spielfeld anzeigen") {
                    router.push(.learningTask(.map))
                }
            }
            
            Button("Vokabelübung starten") {
                router.push(.learningTask(.vocabularyTrainingPage))
            }
            
            Button("Hörverständnis Aufgaben starten") {
                router.push(.learningTask(.listeningComprehensionPage))
            }
            
            Button("Gesprächssimulation starten") {
                router.push(.learningTask(.conversationSimulationPage))
            }
            
            Button("Schreibaufgabe starten") {
                router.push(.learningTask(.writingTaskPage))
            }
            
            Button("fetch ScavengerHunt") {
                Task {
                    await viewModel.fetchScavengerHunt()
                }
            }

        }.navigationDestination(for: Route.self) { route in
            switch route {
            case .learningTask(let learningTaskRoute):
                if let scavengerHunt = viewModel.currentScavengerHunt {
                    router.scavengerHuntDestination(for: learningTaskRoute, scavengerHunt: scavengerHunt)
                }
            default:
                router.destination(for: route)
            }
        }
    }
}
