import FirebaseCore
import UIKit
import FirebaseCore
import FirebaseFirestore
import GooglePlaces

class AppDelegate: NSObject, UIApplicationDelegate {
    let ENV: APIKeyable = ProdENV()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
