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

protocol SnapVocabularyPagePageViewModel: ObservableObject {
    
}

class SnapVocabularyPageViewModelImpl: SnapVocabularyPagePageViewModel {
    @Published var allTasks: [SnapVocabularyTask] = []
    @Published var sharedImageTask: SnapVocabularyTask?
    @Published var isPresented: Bool = false
    @Published var isLoading: Bool = false

    private var imageProcessingManager = ImageProcessingManager()
    @Published var region: MKCoordinateRegion
    let locationManager = LocationManager()
    private let firebaseDataManager = FirebaseDataManager()

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
            allTasks = try await firebaseDataManager.fetchSnapVocabularyTasks()
            // Filter task by radius
//            let snapshots = try await firebaseDataManager.queryLocations(
//                centerLatitude: locationManager.lastKnownLocation?.latitude ?? 0,
//                centerLongitude: locationManager.lastKnownLocation?.longitude ?? 0,
//                radiusInKm: 2
//            )
//
//            self.allTasks = snapshots.compactMap { document in
//                let vocabulary = try? document.data(as: SnapVocabularyTask.self)
//                return vocabulary
//            }
            print("allTasks")
            print(allTasks)
        } catch {
            print("Error fetching tasks: \(error)")
        }
    }
}
