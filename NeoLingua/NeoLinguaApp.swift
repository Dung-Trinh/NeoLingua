import SwiftUI

@main
struct NeoLinguaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var router = RouterImpl()
    @State var isUserLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
    
    var body: some Scene {
        WindowGroup {
            if isUserLoggedIn {
                HomePage(viewModel: HomePageViewModelImpl()).environmentObject(router)
            } else {
                OnboardingPage(viewModel: OnboardingPageViewModelImpl())
                    .onOpenURL { url in
//                        GIDSignIn.sharedInstance.handle(url)
                    }
                    .environmentObject(router)
            }
        }
    }
}
