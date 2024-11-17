import SwiftUI
import FirebaseStorage
import Firebase
import GoogleMaps
import MapKit

struct SnapVocabularyTask: Codable, Identifiable {
    let id: String
    let userId: String
    let coordinates: Location
    let imageUrl: String
    let vocabulary: [String]
}

protocol ImageBasedTaskNearMePageViewModel: ObservableObject {
    
}

class ImageBasedTaskNearMePageViewModelImpl: ImageBasedTaskNearMePageViewModel {
    @Published var allTasks: [SnapVocabularyTask] = []
    @Published var sharedImageTask: SnapVocabularyTask?
    @Published var isPresented: Bool = false
    @Published var isLoading: Bool = false
    
    private var imageProcessingManager = ImageProcessingManager()
    @Published var region: MKCoordinateRegion
    let locationManager = LocationManager()
    
    init() {
        let myPosition = locationManager.lastKnownLocation ??  CLLocationCoordinate2D(latitude: 0, longitude: 0)
        region = MKCoordinateRegion(
            center: myPosition,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
        Task {
            await fetchImageBasedTaskNearMe()
        }
    }
    
    func setPosition() {
        let myPosition = locationManager.lastKnownLocation ??  CLLocationCoordinate2D(latitude: 0, longitude: 0)
        region = MKCoordinateRegion(
            center: myPosition,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    }
    
    @MainActor
    func fetchImageBasedTaskNearMe() {
        Task {
            setPosition()
            await fetchTasks()
        }
    }
    
    func showMarkerDetails(marker: SnapVocabularyTask) {
        sharedImageTask = marker
        
        isPresented = true
    }
    
    
    @MainActor
    func fetchTasks() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let snapshots = try await queryLocations(
                centerLatitude: locationManager.lastKnownLocation?.latitude ?? 0,
                centerLongitude: locationManager.lastKnownLocation?.longitude ?? 0,
                radiusInKm: 2
            )
            
            self.allTasks = snapshots.compactMap { document in
                let vocabulary = try? document.data(as: SnapVocabularyTask.self)
                return vocabulary
            }
            print("allTasks")
            print(allTasks)
        } catch {
            print("Error fetching tasks: \(error)")
        }
    }
    
    func queryLocations(
        centerLatitude: Double,
        centerLongitude: Double,
        radiusInKm: Double
    ) async throws -> [QueryDocumentSnapshot] {
        let db = Firestore.firestore()
        print("centerLatitude: ", centerLatitude)
        print("centerLongitude: ", centerLongitude)
        
        //Berechnung der Bounding Box
        let rangeLat = radiusInKm / 110.574 // ca. 110.574 km pro Breitengrad
        let rangeLon = radiusInKm / (111.320 * cos(centerLatitude * .pi / 180))
        
        let minLat = centerLatitude - rangeLat
        let maxLat = centerLatitude + rangeLat
        let minLon = centerLongitude - rangeLon
        let maxLon = centerLongitude + rangeLon
        
        print("minLat ", minLat)
        print("maxLat ", maxLat)
        print("minLon ", minLon)
        print("maxLon ", maxLon)
        
        let query = db.collection("imageBasedTasks")
            .whereField("coordinates.longitude", isGreaterThanOrEqualTo: minLon)
            .whereField("coordinates.longitude", isLessThanOrEqualTo: maxLon)
            .whereField("coordinates.latitude", isGreaterThanOrEqualTo: minLat)
            .whereField("coordinates.latitude", isLessThanOrEqualTo: maxLat)
        
        let querySnapshot = try await query.getDocuments()
        return querySnapshot.documents
    }
}
