import Foundation
import SwiftUI

enum OnboardingPageNavigation {
    case signup
    case login
}

 protocol OnboardingPageViewModel: ObservableObject {
    var carouselContent: [OnboardingContent] { get }
    
    func loadContent() async
    func navigateTo(_ page: OnboardingPageNavigation)
}

class OnboardingPageViewModelImpl: OnboardingPageViewModel {
    @Published var carouselContent: [OnboardingContent] = []
    
    private let adapter: OnboardingNetworkAdapter
    @Published var router: Router

    init(adapter: OnboardingNetworkAdapter, router: Router) {
        self.adapter = adapter
        self.router = router
    }
    
    func loadContent() async {
//        do {
//            let response = try await adapter.fetchOnboardingContent()
//            carouselContent = response
//            print("resposne: ", response.count)
//        } catch let error {
//            print("err: ", error.localizedDescription)
//        }
    }
    
    func navigateTo(_ page: OnboardingPageNavigation) {
        switch page {
        case .login:
            router.push(.loginSignup(.login))
        case .signup:
            router.push(.loginSignup(.signup))
        }
    }
}
