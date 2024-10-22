import Foundation
import GoogleMaps

protocol ScavengerHuntOverviewPageViewModel: ObservableObject {

}

class ScavengerHuntOverviewPageViewModelImpl: ScavengerHuntOverviewPageViewModel {
    let scavengerHuntManager = ScavengerHuntManager()
    
    @Published var currentScavengerHunt: ScavengerHunt?
    @Published var markers: [GMSMarker] = []

    func fetchScavengerHunt() async {
        do {
            currentScavengerHunt = TestData.scavengerHunt
            if let currentScavengerHunt = currentScavengerHunt {
                markers = await createMarkers(scavengerHunt: currentScavengerHunt)
            }
            
//            currentScavengerHunt = try await scavengerHuntManager.fetchScavengerHunt()
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
