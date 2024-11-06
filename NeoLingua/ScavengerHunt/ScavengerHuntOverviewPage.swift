import SwiftUI

struct ScavengerHuntOverviewPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: ScavengerHuntOverviewPageViewModelImpl
    @State var initialAppearance = false
    
    var body: some View {
        ScrollView {
            if viewModel.scavengerHuntType == .locationBased {
                // Liste mit Competitive ScavengerHunt
                Text("")
            }
            
            VStack {
                if let currentScavengerHunt = viewModel.currentScavengerHunt {
                    PageHeader(
                        title: currentScavengerHunt.title,
                        subtitle: currentScavengerHunt.introduction
                    )
                    Text("Location")
                    if let scavengerHunt = viewModel.currentScavengerHunt {
                        ForEach(scavengerHunt.taskLocations) { location in
                            Label(location.name, systemImage: "mappin.and.ellipse")
                        }
                        VStack {
                            Button(action: {
                                if let scavengerHunt = viewModel.currentScavengerHunt {
                                    router.scavengerHunt = scavengerHunt
                                }
                                router.push(.learningTask(.map))
                            }, label: {
                                Label("Show playing field", systemImage: "map.fill")
                            })
                        }
                        
                        if scavengerHunt.isHuntComplete() {
                            Button("show final result") {
                                viewModel.isPresented = true
                            }
                        }
                    }
                    
                }
            }.onAppear {
                Task {
                    if initialAppearance == false {
                        await viewModel.fetchScavengerHunt()
                        initialAppearance = true
                    } else {
                        await viewModel.updateScavengerHuntState()
                    }
                }
            }
            .sheet(isPresented: $viewModel.isPresented, content: {
                VStack {
                    if let scavengerHuntState = viewModel.currentScavengerHunt?.scavengerHuntState {
                        ForEach(scavengerHuntState.locationTaskPerformance, id: \.self.locationId) {
                            locationPerformance in
                            VStack {
                                Text(locationPerformance.locationName).font(.headline)
                                HStack {
                                    Text("Vocabulary").bold()
                                    if let vocabularyTraining = locationPerformance.performance.vocabularyTraining {
                                        Text(vocabularyTraining.getPointString(maxPoints: 15) )
                                    }
                                }
                                HStack {
                                    Text("ListeningComprehension").bold()
                                    if let listeningComprehension = locationPerformance.performance.listeningComprehension {
                                        Text(listeningComprehension.getPointString(maxPoints: 30) )
                                    }
                                    
                                }
                                HStack {
                                    Text("conversationSimulation").bold()
                                    if let conversationSimulation = locationPerformance.performance.conversationSimulation {
                                        Text(conversationSimulation.getPointString(maxPoints: 40) )
                                    }
                                }
                                HStack {
                                    Text("searchingTheObject").bold()
                                    if let searchingTheObject = locationPerformance.performance.searchingTheObject {
                                        Text(searchingTheObject.getPointString(maxPoints: 15) )
                                    }
                                }
                                
                                Text("\(locationPerformance.getPointsForLocationPerformance()) / 100")
                            }.padding(.bottom, Styleguide.Margin.medium)
                        }
                    }
                    Text(viewModel.getFinalScore()).foregroundStyle(.green).bold()
                }
            })
        }.navigationDestination(for: Route.self) { route in
            router.destination(for: route)
        }
    }
}
