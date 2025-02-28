import Foundation
import GoogleMaps

protocol ScavengerHuntOverviewPageViewModel: ObservableObject {
    var currentScavengerHunt: ScavengerHunt? { get set }
    var isLoading: Bool { get }
    var isLeaderboardPresented: Bool { get set }
    var userScores: [UserScore]? { get }
    var showHelpSheet: Bool { get set }
    var scavengerHuntType: ScavengerHuntType { get }
    var competitiveScavengerHunts: [ScavengerHunt] { get }
    var isPresented: Bool { get set }
    
    func getScavengerHuntLeaderboard() async
    func getFinalScore() -> Double
    func showFinalResult() async
    func fetchScavengerHunt() async
    func updateScavengerHuntState() async
    func setupscavengerHunt() async
}

class ScavengerHuntOverviewPageViewModelImpl: ScavengerHuntOverviewPageViewModel {
    private let scavengerHuntManager = ScavengerHuntManager()
    private let taskProcessManager = TaskProcessManager.shared
    private let leadboardService = LeaderboardServiceImpl()
    private let userDataManager = UserDataManagerImpl()
    let scavengerHuntType: ScavengerHuntType
    
    @Published var isPresented = false
    @Published var isLeaderboardPresented = false
    @Published var currentScavengerHunt: ScavengerHunt?
    @Published var competitiveScavengerHunts: [ScavengerHunt] = []
    @Published var isLoading = false
    @Published var userScores: [UserScore]?
    @Published var markers: [GMSMarker] = []
    @Published var showHelpSheet = false

    init(type: ScavengerHuntType) {
        scavengerHuntType = type
    }
    
    func fetchScavengerHunt() async {
        isLoading = true
        defer { isLoading = false }

        switch scavengerHuntType {
        case .generatedNearMe(let radius, let taskLocationAmount):
            await generateScavengerHuntNearMe(radius: radius, taskLocationAmount: taskLocationAmount)
        case .competitiveMode:
            await fetchCompetitiveScavengerHunts()
        }
    }
    
    func updateScavengerHuntState() async {
        do {
            let scavengerHuntId = currentScavengerHunt?.id ?? ""
            let state = try await taskProcessManager.findScavengerHuntState(scavengerHuntId: scavengerHuntId)
            currentScavengerHunt?.scavengerHuntState = state
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func setupscavengerHunt() async {
        if var currentScavengerHunt = currentScavengerHunt {
            markers = await createMarkers(scavengerHunt: currentScavengerHunt)
            
            let state = ScavengerHuntState(scavengerHunt: currentScavengerHunt)
            currentScavengerHunt.scavengerHuntState = state
            do {
                try await scavengerHuntManager.saveScavengerHuntState(state: state)
                taskProcessManager.currentScavengerHunt = currentScavengerHunt
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getFinalScore() -> Double {
        var finalScore = 0.0
        guard let scavengerHuntState = currentScavengerHunt?.scavengerHuntState else {
            return 0
        }
        for performance in scavengerHuntState.locationTaskPerformance {
            finalScore += performance.getPointsForLocationPerformance()
        }
        return finalScore
    }
    
    func showFinalResult() async {
        isPresented = true
        let finalScore = getFinalScore()
        do {
            try await leadboardService.addPointsForLevel(points: finalScore)
            if scavengerHuntType == .competitiveMode {
                try await userDataManager.addCompetitiveScavengerHuntId(scavengerHuntId: currentScavengerHunt?.id ?? "")
                try await leadboardService.addPointToCompetitiveScavengerHunt(scavengerHuntId: currentScavengerHunt?.id ?? "", points: finalScore)
            }
            
        } catch {
            print("showFinalResult error ", error.localizedDescription)
        }
    }
    
    func getScavengerHuntLeaderboard() async {
        do {
            userScores = try await leadboardService.fetchUserScoresRanking(forHuntId: currentScavengerHunt?.id ?? "")
            isLeaderboardPresented = true
        } catch {
            print("getScavengerHuntLeaderboard error ", error.localizedDescription)
        }
    }
    
    @MainActor
    private func createMarkers(scavengerHunt: ScavengerHunt) -> [GMSMarker] {
        scavengerHunt.taskLocations.map {
            let marker = GMSMarker(
                position:
                    CLLocationCoordinate2D(
                        latitude: $0.location.latitude,
                        longitude: $0.location.longitude
                    )
            )
            marker.title = $0.name
            return marker
        }
    }
    
    private func generateScavengerHuntNearMe(radius: Int, taskLocationAmount: Int) async {
        print("generateScavengerHuntNearMe: ", radius)
        do {
            currentScavengerHunt = try await scavengerHuntManager.generateScavengerHuntNearMe(radius: radius, taskLocationAmount: taskLocationAmount)
            try await setupscavengerHunt()
        } catch {
            print("fetchScavengerHunt error: ", error.localizedDescription)
        }
    }
    
    private func fetchCompetitiveScavengerHunts() async {
        do {
            competitiveScavengerHunts = try await scavengerHuntManager.fetchCompetitiveScavengerHunts()
            try await setupscavengerHunt()
        } catch {
            print("fetchCompetitiveScavengerHunt error: ", error.localizedDescription)
        }
    }
}
