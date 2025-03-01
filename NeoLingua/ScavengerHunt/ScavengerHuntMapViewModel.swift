import Foundation
import GoogleMaps

protocol ScavengerHuntMapViewModel: ObservableObject {
    var scavengerHunt: ScavengerHunt { get set }
    var markers: [GMSMarker] { get set }
    var selectedMarker: GMSMarker? { get set }
    
    func tappedTaskLocation(location: TaskLocation)
    func fetchScavengerHuntState() async
}

class ScavengerHuntMapViewModelImpl: ScavengerHuntMapViewModel {
    private let scavengerHuntManager = ScavengerHuntManagerImpl()

    @Published var selectedMarker: GMSMarker?
    @Published var markers: [GMSMarker] = []
    @Published var scavengerHunt: ScavengerHunt
    @Published var selectedTaskLocation: TaskLocation?
    @Published var router: Router


    init(router: Router, scavengerHunt: ScavengerHunt) {
        self.scavengerHunt = scavengerHunt
        self.router = router
        markers = createMarkers(scavengerHunt: scavengerHunt)
        print(markers)
    }
    
    func tappedTaskLocation(location: TaskLocation) {
        selectedTaskLocation = location
        router.taskLocation = location
        router.push(.scavengerHunt(.taskLocation))
        print(selectedTaskLocation)
    }
    
    func fetchScavengerHuntState() async {
        do {
            let state = try await scavengerHuntManager.fetchScavengerHuntState(scavengerHuntId: scavengerHunt.id)
            scavengerHunt.scavengerHuntState = state
            
            for (index, location) in scavengerHunt.taskLocations.enumerated() {
                for performance in state.locationTaskPerformance {
                    if performance.locationId == scavengerHunt.taskLocations[index].id {
                        scavengerHunt.taskLocations[index].performance = performance
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
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
