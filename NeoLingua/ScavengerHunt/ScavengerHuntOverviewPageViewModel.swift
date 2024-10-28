import Foundation
import GoogleMaps

protocol ScavengerHuntOverviewPageViewModel: ObservableObject {

}

class ScavengerHuntOverviewPageViewModelImpl: ScavengerHuntOverviewPageViewModel {
    let scavengerHuntManager = ScavengerHuntManager()
    
    @Published var currentScavengerHunt: ScavengerHunt?
    @Published var markers: [GMSMarker] = []

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
            if let currentScavengerHunt = currentScavengerHunt {
                markers = await createMarkers(scavengerHunt: currentScavengerHunt)
            }
        } catch {
            print("fetchScavengerHunt error: ", error.localizedDescription)
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
