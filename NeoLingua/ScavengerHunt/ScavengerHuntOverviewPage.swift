import SwiftUI

struct ScavengerHuntOverviewPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: ScavengerHuntOverviewPageViewModelImpl
    @State var initialAppearance = false
    
    var body: some View {
        ScrollView {
            if viewModel.scavengerHuntType == .competitiveMode && viewModel.currentScavengerHunt == nil  {
                Text("ⓘ Choose a scavenger hunt near your location")

                Text("CompetitiveScavengerHunt List")
                ForEach(Array(viewModel.competitiveScavengerHunts.enumerated()), id: \.element.id ) { index, scavengerHunt in
                    HStack {
                        Text("\(index + 1).")
                        Button(scavengerHunt.title) {
                            viewModel.currentScavengerHunt = scavengerHunt
                            Task {
                                await try? viewModel.setupscavengerHunt()
                            }
                        }
                    }
                }
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
                                Task {
                                    await viewModel.showFinalResult()
                                }
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
            .sheet(isPresented: $viewModel.isPresented, onDismiss: {
                router.navigateToRoot()
            }) {
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
                                Button("show leaderboard for this scavenger hunt") {
                                    Task {
                                        await viewModel.getScavengerHuntLeaderboard()
                                    }
                                }
                            }.padding(.bottom, Styleguide.Margin.medium)
                        }
                    }
                    Text(String(format: "%.2f", viewModel.getFinalScore())).foregroundStyle(.green).bold()
                    PrimaryButton(
                        title: "back to menu",
                        color: .blue,
                        action: {
                            router.navigateToRoot()
                        }
                    )
                }.sheet(isPresented: $viewModel.isLeaderboardPresented, content: {
                    LeaderboardView(userScores: viewModel.userScores ?? [])
                })
            }
        }.navigationDestination(for: Route.self) { route in
            router.destination(for: route)
        }
        .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
    }
}
