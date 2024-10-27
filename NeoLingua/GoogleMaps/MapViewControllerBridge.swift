import GoogleMaps
import SwiftUI

struct MapViewControllerBridge: UIViewControllerRepresentable {
    @Binding var markers: [GMSMarker]
    @Binding var selectedMarker: GMSMarker?
    
    var onAnimationEnded: () -> ()
    var mapViewWillMove: (Bool) -> ()
    
    func makeUIViewController(context: Context) -> MapViewController {
        let uiViewController = MapViewController()
        uiViewController.markers = markers
        uiViewController.map.delegate = context.coordinator
        return uiViewController
    }
    
    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
        markers.forEach { $0.map = uiViewController.map }
        selectedMarker?.map = uiViewController.map
        animateToSelectedMarker(viewController: uiViewController)
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator(self)
    }
    
    private func animateToSelectedMarker(viewController: MapViewController) {
        guard let selectedMarker = selectedMarker else {
            return
        }
        
        let map = viewController.map
        if map.selectedMarker != selectedMarker {
            map.selectedMarker = selectedMarker
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                map.animate(with: GMSCameraUpdate.setTarget(selectedMarker.position))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    map.animate(toZoom: 15)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onAnimationEnded()
                    }
                }
            }
        }
    }
    
    class MapViewCoordinator: NSObject, GMSMapViewDelegate {
        var mapViewControllerBridge: MapViewControllerBridge
        
        init(_ mapViewControllerBridge: MapViewControllerBridge) {
            self.mapViewControllerBridge = mapViewControllerBridge
        }
        
        func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
            self.mapViewControllerBridge.mapViewWillMove(gesture)
        }
    }
}
