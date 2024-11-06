import Foundation
import GoogleMaps

protocol ScavengerHuntOverviewPageViewModel: ObservableObject {

}

class ScavengerHuntOverviewPageViewModelImpl: ScavengerHuntOverviewPageViewModel {
    let scavengerHuntManager = ScavengerHuntManager()
    let scavengerHuntType: ScavengerHuntType
    @Published var isPresented = false
    @Published var currentScavengerHunt: ScavengerHunt?
    @Published var markers: [GMSMarker] = []
    
    private var taskProcessManager = TaskProcessManager.shared
    var leadboardService = LeaderboardService()
    
    init(type: ScavengerHuntType) {
        scavengerHuntType = type
        switch type {
        case .generatedNearMe: break
            //location ermitteln und assistant fragen
        case .locationBased: break
            // von firebase db fragen
        }
    }
    
    func fetchScavengerHunt() async {
        do {
            currentScavengerHunt = try await scavengerHuntManager.fetchScavengerHuntNearMe()
            if var currentScavengerHunt = currentScavengerHunt {
                markers = await createMarkers(scavengerHunt: currentScavengerHunt)
                try await scavengerHuntManager.saveScavengerHunt(scavengerHunt: currentScavengerHunt)
                
                
                let state = ScavengerHuntState(scavengerHunt: currentScavengerHunt)

                currentScavengerHunt.scavengerHuntState = state
                try await scavengerHuntManager.saveScavengerHuntState(state: state)
                
//                router.scavengerHunt = currentScavengerHunt
                taskProcessManager.currentScavengerHunt = currentScavengerHunt
            }
        } catch {
            print("fetchScavengerHunt error: ", error.localizedDescription)
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
        } catch {
            print("showFinalResult error ", error.localizedDescription)
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
}
