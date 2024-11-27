import SwiftUI
import Lottie

struct ScavengerHuntOverviewPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: ScavengerHuntOverviewPageViewModelImpl
    @State var initialAppearance = false
    @State var showHelpSheet = false
    
    var body: some View {
        VStack {
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
                        ScrollView {
                            if let scavengerHuntState = viewModel.currentScavengerHunt?.scavengerHuntState {
                                Text("Locations")
                                    .font(.title)
                                ForEach(scavengerHuntState.locationTaskPerformance, id: \.self.locationId) {
                                    locationPerformance in
                                    VStack {
                                        Text(locationPerformance.locationName)
                                            .font(.title3)
                                            .bold()
                                            .foregroundColor(.blue)
                                        
                                        if let vocabularyTraining = locationPerformance.performance.vocabularyTraining {
                                            TaskResultTile(
                                                title: "Vocabulary",
                                                points: vocabularyTraining.getPointString(maxPoints: 15)
                                            )
                                        }
                                        
                                        if let listeningComprehension = locationPerformance.performance.listeningComprehension {
                                            TaskResultTile(
                                                title: "Listening Comprehension",
                                                points: listeningComprehension.getPointString(maxPoints: 30)
                                            )
                                        }
                                        
                                        if let conversationSimulation = locationPerformance.performance.conversationSimulation {
                                            TaskResultTile(
                                                title: "Conversation Simulation",
                                                points: conversationSimulation.getPointString(maxPoints: 40)
                                            )
                                        }
                                        
                                        if let searchingTheObject = locationPerformance.performance.searchingTheObject {
                                            TaskResultTile(
                                                title: "Searching the Object",
                                                points: searchingTheObject.getPointString(maxPoints: 15)
                                            )
                                        }
                                        Text("\(locationPerformance.getPointsForLocationPerformance(), specifier: "%.2f") / 100 points")
                                            .font(.headline)
                                            .padding(.top)
                                        if viewModel.scavengerHuntType == .competitiveMode {
                                            Button("Show leaderboard for this scavenger hunt") {
                                                Task {
                                                    await viewModel.getScavengerHuntLeaderboard()
                                                }
                                            }.font(.body)
                                        }
                                        
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(12)
                                }
                            }
                            Spacer()
                            LottieView(animation: .named("cupAnimation"))
                                .looping()
                                .frame(width: .infinity, height: 300)
                        }
                        Spacer()
                        Text("Final Score: \(String(format: "%.2f", viewModel.getFinalScore()))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top)
                        PrimaryButton(
                            title: "Back to menu",
                            color: .blue,
                            action: {
                                router.navigateToRoot()
                            }
                        )
                    }.padding()
                    .sheet(isPresented: $viewModel.isLeaderboardPresented, content: {
                        VStack {
                            Text("Leaderboard of the scavenger hunt")
                            LeaderboardView(userScores: viewModel.userScores ?? [])
                        }.padding()
                    })
                }
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
                ).padding(.horizontal, Styleguide.Margin.medium)
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

struct TaskResultTile: View {
    let title: String
    let points: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            Spacer()
            Text(points)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}
