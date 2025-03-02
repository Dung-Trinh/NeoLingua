import Foundation
import CoreLocation
import Alamofire

final class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    @Published var lastKnownLocation: CLLocationCoordinate2D?
    @Published var nearbyTaskLocation: [TaskLocation] = []
    var taskLocations: [TaskLocation] = []
    
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
            lastKnownLocation = manager.location?.coordinate
            
        @unknown default:
            print("Location service disabled")
        
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        nearbyTaskLocation = []
        lastKnownLocation = locations.first?.coordinate
        
        for taskLocation in taskLocations {
            let isInRadius = checkIfWithinRadius(currentLocation: location, targetLocation: CLLocation(latitude: taskLocation.location.latitude, longitude: taskLocation.location.longitude), radius: 20)
            if isInRadius {
                nearbyTaskLocation.append(taskLocation)
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get users location.")
    }
    
    func checkIfWithinRadius(currentLocation: CLLocation, targetLocation: CLLocation, radius: Double) -> Bool {
        let distanceInMeters = currentLocation.distance(from: targetLocation)
        
        return distanceInMeters <= radius
    }
    
    func checkIfLocationIsNearby(_ currentLocation: TaskLocation) -> Bool {
        return nearbyTaskLocation.contains(currentLocation)
    }
}
