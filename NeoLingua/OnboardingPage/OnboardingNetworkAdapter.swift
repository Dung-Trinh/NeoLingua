import Alamofire

protocol OnboardingNetworkAdapter {
    func fetchOnboardingContent() async throws -> [OnboardingContent]
}

class OnboardingNetworkAdapterImpl: OnboardingNetworkAdapter {
    func fetchOnboardingContent() async throws -> [OnboardingContent] {
        let urlString = "http://localhost:3000/onboardingContent"
        return try await AF.request(urlString)
            .serializingDecodable(OnboardingOnboardingContentResponse.self)
            .value
            .content
    }
}
