import GoogleMaps
import SwiftUI
import UIKit

class MapViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    var map = GMSMapView()
    var isAnimating: Bool = false
    var markers: [GMSMarker] = []
    
    override func loadView() {
        super.loadView()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let (centerCoordinate, radius) = calculateCenterAndRadius()

        let camera = GMSCameraPosition.camera(
            withLatitude: centerCoordinate.latitude,
            longitude: centerCoordinate.longitude,
            zoom: 14.5
        )
        map = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        map.isMyLocationEnabled = true
        map.settings.myLocationButton = true
        
        drawRadiusCircle(at: centerCoordinate, radius: radius)
        self.view.addSubview(map)
    }
    
    func drawRadiusCircle(at center: CLLocationCoordinate2D, radius: CLLocationDistance, color: UIColor? = nil) {
        let circle = GMSCircle(position: center, radius: radius)
        if (color != nil) {
            circle.fillColor = color?.withAlphaComponent(0.1)
        } else {
            circle.fillColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.1)
        }
        circle.strokeColor = .blue
        circle.strokeWidth = 2
        circle.map = map
    }
    
    func calculateCenterAndRadius() -> (CLLocationCoordinate2D, CLLocationDistance) {
        var totalLatitude: CLLocationDegrees = 0
        var totalLongitude: CLLocationDegrees = 0
        
        markers.forEach { spot in
            totalLatitude += spot.position.latitude
            totalLongitude += spot.position.longitude
        }
        
        let centerLatitude = totalLatitude / Double(markers.count)
        let centerLongitude = totalLongitude / Double(markers.count)
        let centerCoordinate = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
        
        let centerLocation = CLLocation(latitude: centerLatitude, longitude: centerLongitude)
        var maxDistance: CLLocationDistance = 0
        
        markers.forEach { spot in
            let location = CLLocation(latitude: spot.position.latitude, longitude: spot.position.longitude)
            let distance = centerLocation.distance(from: location)
            maxDistance = max(maxDistance, distance)
        }
        
        let paddedRadius = maxDistance * 1.2
        return (centerCoordinate, paddedRadius)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let targetLocation = CLLocation(latitude: 50.085472, longitude: 8.251848)
        let distanceInMeters = location.distance(from: targetLocation)
        
        let isInRadius = checkIfWithinRadius(currentLocation: location, targetLocation: targetLocation, radius: 50)
        drawRadiusCircle(at: CLLocationCoordinate2D(latitude: 50.085472, longitude: 8.251848), radius: 50, color: UIColor.red)
        print("distanceInMeters: ", distanceInMeters)
        print("isInRadius: ", isInRadius)
        // center camera when user location is available
//        guard let location = locations.first else { return }
//        
//        let camera = GMSCameraPosition.camera(
//            withLatitude: location.coordinate.latitude,
//            longitude: location.coordinate.longitude,
//            zoom: 15.0
//        )
//        map.animate(to: camera)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func checkIfWithinRadius(currentLocation: CLLocation, targetLocation: CLLocation, radius: Double) -> Bool {
        let distanceInMeters = currentLocation.distance(from: targetLocation)
        
        return distanceInMeters <= radius
    }
}
