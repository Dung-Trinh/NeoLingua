import FirebaseCore
import UIKit
import FirebaseCore
import FirebaseFirestore
import GooglePlaces
import GoogleMaps

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        GMSServices.provideAPIKey(ProdENV().GOOGLE_MAPS_KEY)
        GMSPlacesClient.provideAPIKey(ProdENV().GOOGLE_MAPS_KEY)
        
        let arguments = CommandLine.arguments
        if arguments.contains("--useMockData") {
            print("--- USE MOCK DATA ---")
        } else {
            print(arguments)
        }
        return true
    }
}
