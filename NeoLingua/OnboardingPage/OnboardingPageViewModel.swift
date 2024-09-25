import Foundation
import SwiftUI

 protocol OnboardingPageViewModel: ObservableObject {
    var carouselContent: [OnboardingContent] { get }
    
    func loadContent() async
}

class OnboardingPageViewModelImpl: OnboardingPageViewModel {
    @Published var carouselContent: [OnboardingContent] = []
    
    private let adapter: OnboardingNetworkAdapter
    
    init(adapter: OnboardingNetworkAdapter) {
        self.adapter = adapter
    }
    
    convenience init() {
        self.init(adapter: OnboardingNetworkAdapterImpl())
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
}
