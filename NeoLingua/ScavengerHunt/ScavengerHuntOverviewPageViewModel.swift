import Foundation
import GoogleMaps

protocol ScavengerHuntOverviewPageViewModel: ObservableObject {

}

class ScavengerHuntOverviewPageViewModelImpl: ScavengerHuntOverviewPageViewModel {
    let scavengerHuntManager = ScavengerHuntManager()
    
    @Published var currentScavengerHunt: ScavengerHunt?
    @Published var markers: [GMSMarker] = []
    
    private var taskProcessManager = TaskProcessManager.shared

    init(type: ScavengerHuntType) {
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
