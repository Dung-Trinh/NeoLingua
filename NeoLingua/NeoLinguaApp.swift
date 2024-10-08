import SwiftUI

@main
struct NeoLinguaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var router = Router()
    @State var isUserLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
    
    var body: some Scene {
        WindowGroup {
            if isUserLoggedIn {
                HomePage(viewModel: HomePageViewModelImpl())
                    .environmentObject(Router())
            } else {
                OnboardingPage(viewModel: OnboardingPageViewModelImpl())
                    .environmentObject(Router())

//                    .onOpenURL { url in
////                        GIDSignIn.sharedInstance.handle(url)
//                    }
            }
        }
    }
}
