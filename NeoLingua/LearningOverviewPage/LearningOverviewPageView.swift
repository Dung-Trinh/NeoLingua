import Foundation
import CoreLocation
import FirebaseDatabase
import FirebaseCore
import FirebaseFirestore
import GooglePlaces
import Alamofire

protocol LearningOverviewPageView: ObservableObject {
    func setupRouter(_ router: RouterImpl)
    func getLocation()
    func fetchLocation() async throws
}

class LearningOverviewPageViewImpl: LearningOverviewPageView {
    private var router: RouterImpl?
    private var listenerRegistration: ListenerRegistration?
    private var placesClient = GMSPlacesClient.shared()

    func setupRouter(_ router: RouterImpl) {
        self.router = router
    }
    
    func getLocation() {
        let locationManager = LocationManager()
        locationManager.checkLocationAuthorization()
        
        let locationManager2 = CLLocationManager()
        locationManager2.requestAlwaysAuthorization()
        
        let placesClient = GMSPlacesClient.shared()
        let fields: GMSPlaceField = [.name, .coordinate]
        
        placesClient.findPlaceLikelihoodsFromCurrentLocation(
            withPlaceFields: fields,
            callback: {
                (placeLikelihoodList: Array<GMSPlaceLikelihood>?, error: Error?) in
                if let error = error {
                    print("An error occurred: \(error.localizedDescription)")
                    return
                }
                
                if let placeLikelihoodList = placeLikelihoodList {
                    for likelihood in placeLikelihoodList {
                        let place = likelihood.place
                        print("Current Place name \(String(describing: place.name)) at likelihood \(likelihood.likelihood)")
                        print("Current PlaceID \(String(describing: place.placeID))")
                    }
                }
            })
    }
    
    func fetchLocation() async throws {
        await findNearbyPlaces()
        
        let locationManager = LocationManager()
        let fetchedPlaces = try await locationManager.fetchNearbyPlaces(location: nil)
        print("fetchedPlaces")
        print(fetchedPlaces.count)

    }
    
   @MainActor
    func findNearbyPlaces() {

    }
}

// Datenmodelle für die API-Antwort
struct LocationResponse: Codable {
    let location: Location
    let accuracy: Double
}

struct Location: Codable {
    let lat: Double
    let lng: Double
}
