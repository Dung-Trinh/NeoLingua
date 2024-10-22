import SwiftUI

struct ScavengerHuntOverviewPage: View {
    @EnvironmentObject private var router: Router
    @StateObject private var viewModel = ScavengerHuntOverviewPageViewModelImpl()
    
    var body: some View {
        ScrollView {
            if let currentScavengerHunt = viewModel.currentScavengerHunt {
                PageHeader(
                    title: "ScavengerHunt",
                    subtitle: currentScavengerHunt.introduction
                )
                
                Text("Location")
                VStack {
                    if let scavengerHunt = viewModel.currentScavengerHunt {
                        Button("Spielfeld anzeigen") {
                            if let scavengerHunt = viewModel.currentScavengerHunt {
                                router.scavengerHunt = scavengerHunt
                            }
                            router.push(.learningTask(.map))
                        }
                        
//                        Button("Vokabelübung starten") {
////                            router.push(.learningTask(.vocabularyTrainingPage))
//                        }
                    }
                    
                    
//                    Button("Hörverständnis Aufgaben starten") {
////                        router.push(.learningTask(.listeningComprehensionPage))
//                    }
//                    
//                    Button("Gesprächssimulation starten") {
////                        router.push(.learningTask(.conversationSimulationPage))
//                    }
//                    
//                    Button("Schreibaufgabe starten") {
////                        router.push(.learningTask(.writingTaskPage))
//                    }
                }
            }
            Button("fetch ScavengerHunt") {
                Task {
                    await viewModel.fetchScavengerHunt()
                }
            }
            Button("Foto schießen und Lerninhalte generien lassen") {
                router.push(.imageBasedLearningPage)
            }
        }.navigationDestination(for: Route.self) { route in
                router.destination(for: route)
        }
    }
}
