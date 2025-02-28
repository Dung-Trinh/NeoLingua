import Foundation
import MapKit

protocol ScavengerHuntInfoPageViewModel: ObservableObject {
    var userLocation: CLLocationCoordinate2D? { get }
    var radius: Double { get set }
    var isCustomRadiusActive: Bool { get set }
    var locationAmount: Int { get set }
    
    func fetchUserLocation()
    func navigateTo(route: ScavengerHuntRoute)
}

class ScavengerHuntInfoPageViewModelImpl: ScavengerHuntInfoPageViewModel {
    private let locationManager = LocationManager()
    private let router: Router
    
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var radius: Double = 200.0
    @Published var isCustomRadiusActive: Bool = false
    @Published var locationAmount: Int = 1
    
    init(router: Router) {
        self.router = router
    }
    
    func fetchUserLocation() {
        locationManager.requestLocation()
        locationManager.checkLocationAuthorization()
        guard let lastKnownLocation = locationManager.lastKnownLocation else {
            print("lastKnownLocation is nil")
            return
        }
        print(lastKnownLocation)
        userLocation = CLLocationCoordinate2D(
            latitude: lastKnownLocation.latitude,
            longitude: lastKnownLocation.longitude
        )
    }
    
    func navigateTo(route: ScavengerHuntRoute) {
        switch route {
        case .scavengerHunt(.generatedNearMe):
            router.push(.scavengerHunt(.scavengerHunt(.generatedNearMe(Int(radius),locationAmount))))
        case .scavengerHunt(.competitiveMode):
            router.push(.scavengerHunt(.scavengerHunt(.competitiveMode)))
        default:
            break
        }
    }
}
