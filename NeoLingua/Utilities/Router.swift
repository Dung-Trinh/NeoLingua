import SwiftUI

enum Route: Hashable {
    
    case loginSignup(LoginSignupRoute)
    case scavengerHunt(ScavengerHuntRoute)
    case homePage
    case onboardingPage
    
    enum LoginSignupRoute: Hashable {
        case login
        case signup
        case signupData
        case successfullyRegistered
    }
    
    enum ScavengerHuntRoute: Hashable {
        case overview
        case map
    }
}


//@Observable
class Router: ObservableObject  {
    @Published var routes: [Route] = []
    let startEmptyStackViews: [Route] = [
        .loginSignup(.login),
        .loginSignup(.signup),
        .onboardingPage
    ]

    @ViewBuilder
    func destination(for route: Route) -> some View {
        switch route {
            case .loginSignup(let loginSignupRoute):
                handleLoginSignupRoutes(loginSignupRoute)
            case .homePage:
                HomePage(viewModel: HomePageViewModelImpl())
            case .onboardingPage:
                OnboardingPage(viewModel: OnboardingPageViewModelImpl())
        case .scavengerHunt(let scavengerHuntRoute):
                handleScavengerHuntRoutes(scavengerHuntRoute)
        }
    }
    
    func push(_ route: Route) {
        if startEmptyStackViews.contains(route) {
            routes.removeAll()
        }
        routes.append(route)
    }
    
    @ViewBuilder
    private func handleLoginSignupRoutes(_ loginSignupRoute: Route.LoginSignupRoute) -> some View {
        switch loginSignupRoute {
            case .login:
                LoginPage(viewModel: LoginPageViewModelImpl(router: self))
            case .signup:
                SignupPage(viewModel: SignupPageViewModelImpl(router: self))
            case .signupData:
                SignupUserDataPage(viewModel: SignupUserDataPageViewModelImpl(router: self))
            case .successfullyRegistered:
                SignupSuccessPage()
        }
    }
    
    @ViewBuilder
    private func handleScavengerHuntRoutes(_ scavengerHuntRoute: Route.ScavengerHuntRoute) -> some View {
        switch scavengerHuntRoute {
            case .overview:
                ScavengerHuntOverviewPage()
            case .map:
                ScavengerHuntMap()
        }
    }
}
