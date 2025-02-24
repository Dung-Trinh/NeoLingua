import SwiftUI
import FirebaseStorage
import Firebase
import GoogleMaps
import MapKit

protocol SnapVocabularyPageViewModel: ObservableObject {
    var allTasks: [SnapVocabularyTask] { get }
    var sharedImageTask: SnapVocabularyTask? { get }
    var isPresented: Bool { get set }
    var isLoading: Bool { get }
    var region: MKCoordinateRegion { get set }
    
    func showMarkerDetails(marker: SnapVocabularyTask)
}

class SnapVocabularyPageViewModelImpl: SnapVocabularyPageViewModel {
    private let imageProcessingManager = ImageProcessingManager()
    private let locationManager = LocationManager()
    private let firebaseDataManager = FirebaseDataManagerImpl()
    
    @Published var allTasks: [SnapVocabularyTask] = []
    @Published var sharedImageTask: SnapVocabularyTask?
    @Published var isPresented: Bool = false
    @Published var isLoading: Bool = false
    @Published var region: MKCoordinateRegion

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
    
    func showMarkerDetails(marker: SnapVocabularyTask) {
        sharedImageTask = marker
        
        isPresented = true
    }
    
    private func setPosition() {
        let myPosition = locationManager.lastKnownLocation ??  CLLocationCoordinate2D(latitude: 0, longitude: 0)
        region = MKCoordinateRegion(
            center: myPosition,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    }
    
    @MainActor
    private func fetchImageBasedTaskNearMe() {
        Task {
            setPosition()
            await fetchTasks()
        }
    }
}
