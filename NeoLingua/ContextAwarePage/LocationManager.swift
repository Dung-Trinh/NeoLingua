import Foundation
import CoreLocation
import Alamofire

final class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    @Published var lastKnownLocation: CLLocationCoordinate2D?
    let manager = CLLocationManager()
    
    override init() {
        super.init()
        self.manager.delegate = self
        self.manager.requestWhenInUseAuthorization()
        self.manager.startUpdatingLocation()
    }
    
    func requestLocation() {
        manager.requestLocation()
    }
    
    func checkLocationAuthorization() {
        switch manager.authorizationStatus {
        case .notDetermined://The user choose allow or denny your app to get the location yet
            manager.requestWhenInUseAuthorization()
            
        case .restricted://The user cannot change this app’s status, possibly due to active restrictions such as parental controls being in place.
            print("Location restricted")
            
        case .denied://The user dennied your app to get location or disabled the services location or the phone is in airplane mode
            print("Location denied")
            
        case .authorizedAlways://This authorization allows you to use all location services and receive location events whether or not your app is in use.
            print("Location authorizedAlways")
            
        case .authorizedWhenInUse://This authorization allows you to use all location services and receive location events only when your app is in use
            print("Location authorized when in use")
            lastKnownLocation = manager.location?.coordinate
            
        @unknown default:
            print("Location service disabled")
        
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.first?.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get users location.")
    }
    
    func fetchNearbyPlaces(location: CLLocation?) async throws -> [Place] {
        let apiKey = ProdENV().GOOGLE_MAPS_KEY
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        
        let parameters: [String: Any] = [
            "location": "\(50.083163852799835),\(8.245660299715162)",
            "radius": 1000,
            "type": "point_of_interest",
            "key": apiKey
        ]
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(urlString, method: .get, parameters: parameters).responseDecodable(of: PlacesResponse.self) { response in
                switch response.result {
                case .success(let placesResponse):
                    print("nearbysearch success")
                    continuation.resume(returning: placesResponse.results)
                case .failure(let error):
                    print("nearbysearch err")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

struct Place: Codable {
    let name: String
    let vicinity: String
}

struct PlacesResponse: Codable {
    let results: [Place]
}
