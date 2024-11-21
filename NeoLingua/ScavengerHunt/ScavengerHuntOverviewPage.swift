import SwiftUI

struct ScavengerHuntOverviewPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: ScavengerHuntOverviewPageViewModelImpl
    @State var initialAppearance = false
    @State var showHelpSheet = false
    
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
                                try? await viewModel.setupscavengerHunt()
                            }
                        }
                    }
                }
            }
            
            VStack(alignment: .leading) {
                if let currentScavengerHunt = viewModel.currentScavengerHunt {
                    PageHeader(
                        title: currentScavengerHunt.title,
                        subtitle: currentScavengerHunt.introduction,
                        textAlignment: .leading
                    ).padding(.bottom, Styleguide.Margin.medium)
                    
                    Text("Location").font(.headline)
                    VStack(alignment: .leading, spacing: Styleguide.Margin.small) {
                        if let scavengerHunt = viewModel.currentScavengerHunt {
                            ForEach(scavengerHunt.taskLocations) { location in
                                Text("📍\(location.name)").multilineTextAlignment(.leading)
                            }
                        }
                    }.padding(.bottom, Styleguide.Margin.medium)
                    
                    HStack {
                        Spacer()
                        Button {
                            if let scavengerHunt = viewModel.currentScavengerHunt {
                                router.scavengerHunt = scavengerHunt
                            }
                            router.push(.learningTask(.map))
                        } label: {
                            Text("Show playing field")
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.accentColor)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.accentColor, lineWidth: 1)
                                )
                        }
                        Spacer()
                    }
                    
                    if viewModel.currentScavengerHunt?.isHuntComplete() == true {
                        Spacer()
                        PrimaryButton(
                            title: "Show final result",
                            color: .blue,
                            action: {
                                Task {
                                    await viewModel.showFinalResult()
                                }
                            }
                        )
                    }
                }
            }
            .padding()
            .onAppear {
                Task {
                    if initialAppearance == false {
                        initialAppearance = true
                        await viewModel.fetchScavengerHunt()
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
        }
        .navigationDestination(for: Route.self) { route in
            router.destination(for: route)
        }
        .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Need help?") {
                    showHelpSheet = true
                }.sheet(isPresented: $showHelpSheet) {
                    ScavengerHuntHelpView()
                        .presentationDetents([.fraction(0.8)])
                        .presentationCornerRadius(40)
                }
            }
        }
    }
}


struct ScavengerHuntHelpView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image("scavengerHuntHelpImage")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                Text("How it works:").font(.title).bold()
                VStack(alignment: .leading, spacing: 8) {
                    Text("**1. Discover locations:** Check out the list of available locations in the overview.")
                    Text("**2. Switch to the map:** Use the 'Show playing field' button to see the locations on the map.")
                    Text("**3. Move to the location:** Get closer to a location to unlock and start the tasks.")
                    Text("**4. Complete the tasks:** Once you're close enough, solve the tasks and get points!")
                }
                .font(.body)
            }
            .padding()
            .navigationTitle("Instruction")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
