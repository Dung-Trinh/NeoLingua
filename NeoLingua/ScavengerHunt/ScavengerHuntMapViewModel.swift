import Foundation
import GoogleMaps

protocol ScavengerHuntMapViewModel: ObservableObject {

}

class ScavengerHuntMapViewModelImpl: ScavengerHuntMapViewModel {
    @Published var selectedMarker: GMSMarker?
    @Published var markers: [GMSMarker] = []

    init(scavengerHunt: ScavengerHunt) {
        markers = createMarkers(scavengerHunt: scavengerHunt)
        print(markers)
    }
    
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
