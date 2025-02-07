import SwiftUI

@main
struct NeoLinguaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var router = Router()
    @State var isUserLoggedIn = UserDefaults.standard.isUserLoggedIn()
    
    var body: some Scene {
        WindowGroup {
            if isUserLoggedIn {
                HomePage(viewModel: HomePageViewModelImpl())
                    .environmentObject(router)
            } else {
                OnboardingPage(viewModel: OnboardingPageViewModelImpl())
                    .environmentObject(router)
            }
        }
    }
}
