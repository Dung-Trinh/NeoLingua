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

    private var imageProcessingManager = ImageProcessingManager()
    @Published var region: MKCoordinateRegion
    let locationManager = LocationManager()

    init() {
        let myPosition = locationManager.lastKnownLocation ??  CLLocationCoordinate2D(latitude: 0, longitude: 0)
        region = MKCoordinateRegion(
            center: myPosition,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
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
        let db = Firestore.firestore()
        
        do {
            let snapshot = try await db.collection("imageBasedTasks").getDocuments()
            
            self.allTasks = snapshot.documents.compactMap { document in
                try? document.data(as: SnapVocabularyTask.self)
            }
            print("allTasks")
            print(allTasks)
        } catch {
            print("Error fetching tasks: \(error)")
        }
    }
}
