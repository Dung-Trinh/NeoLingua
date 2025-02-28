import SwiftUI
import Lottie

struct ScavengerHuntResultPage: View {
    @StateObject var viewModel: ScavengerHuntOverviewPageViewModelImpl
    @EnvironmentObject private var router: Router
    
    var body: some View {
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
