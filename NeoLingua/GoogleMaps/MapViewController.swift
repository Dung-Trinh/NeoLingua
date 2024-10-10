import GoogleMaps
import SwiftUI
import UIKit

let pointOfInterestSpots = [
    PointOfInterest(name: "Spielbank Wiesbaden", coordinate: CLLocationCoordinate2D(latitude: 50.083091, longitude: 8.243167)),
    PointOfInterest(name: "Kurpark Wiesbaden", coordinate: CLLocationCoordinate2D(latitude: 50.085472, longitude: 8.254062)),
    PointOfInterest(name: "Warmer Damm", coordinate: CLLocationCoordinate2D(latitude: 50.081240, longitude: 8.246010))
]

class MapViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    var map = GMSMapView()
    var isAnimating: Bool = false
    
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
    
    func drawRadiusCircle(at center: CLLocationCoordinate2D, radius: CLLocationDistance) {
        let circle = GMSCircle(position: center, radius: radius)
        circle.fillColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.1)
        circle.strokeColor = .blue
        circle.strokeWidth = 2
        circle.map = map
    }
    
    func calculateCenterAndRadius() -> (CLLocationCoordinate2D, CLLocationDistance) {
        var totalLatitude: CLLocationDegrees = 0
        var totalLongitude: CLLocationDegrees = 0
        
        pointOfInterestSpots.forEach { spot in
            totalLatitude += spot.coordinate.latitude
            totalLongitude += spot.coordinate.longitude
        }
        
        let centerLatitude = totalLatitude / Double(pointOfInterestSpots.count)
        let centerLongitude = totalLongitude / Double(pointOfInterestSpots.count)
        let centerCoordinate = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
        
        let centerLocation = CLLocation(latitude: centerLatitude, longitude: centerLongitude)
        var maxDistance: CLLocationDistance = 0
        
        pointOfInterestSpots.forEach { spot in
            let location = CLLocation(latitude: spot.coordinate.latitude, longitude: spot.coordinate.longitude)
            let distance = centerLocation.distance(from: location)
            maxDistance = max(maxDistance, distance)
        }
        
        let paddedRadius = maxDistance * 1.2
        return (centerCoordinate, paddedRadius)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
}
