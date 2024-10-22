import SwiftUI

enum Route: Hashable {
    
    case loginSignup(LoginSignupRoute)
    case scavengerHunt(ScavengerHuntRoute)
    case learningTask(LearningTaskRoute)
    case homePage
    case onboardingPage
    case taskLocation
    
    
    enum LoginSignupRoute: Hashable {
        case login
        case signup
        case signupData
        case successfullyRegistered
    }
    
    enum ScavengerHuntRoute: Hashable {
        case overview
        case taskLocation
    }
    
    enum LearningTaskRoute: Hashable {
        case map
        case vocabularyTrainingPage(prompt: String)
        case listeningComprehensionPage(prompt: String)
        case conversationSimulationPage(prompt: String)
        case writingTaskPage(prompt: String)
    }
}
//@Observable
class Router: ObservableObject  {
    @Published var routes: [Route] = []
    
    var taskLocation: TaskLocation? = nil
    var scavengerHunt: ScavengerHunt? = nil

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
        case .learningTask(let learningTaskRoute):
            if let scavengerHunt = scavengerHunt {
                scavengerHuntDestination(for: learningTaskRoute, scavengerHunt: scavengerHunt)
            }
        case .taskLocation:
            if let taskLocation = taskLocation {
                TaskLocationPage(viewModel: TaskLocationPageViewModelImpl(taskLocation: taskLocation))
            }
        }
    }
    
    @ViewBuilder
    func scavengerHuntDestination(
        for route: Route.LearningTaskRoute,
        scavengerHunt: ScavengerHunt
    ) -> some View {
        handleLearningTaskRoute(route, scavengerHunt: scavengerHunt)
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
        case .taskLocation:
            if let taskLocation = taskLocation {
                TaskLocationPage(viewModel: TaskLocationPageViewModelImpl(taskLocation: taskLocation))
            }
        }
    }
    
    @ViewBuilder
    private func handleLearningTaskRoute(
        _ learningTaskRoute: Route.LearningTaskRoute,
        scavengerHunt: ScavengerHunt
    ) -> some View {
        switch learningTaskRoute {
        case .vocabularyTrainingPage(let prompt):
            VocabularyTrainingPage(viewModel: VocabularyTrainingPageViewModelImpl(prompt: prompt))
        case .listeningComprehensionPage(let prompt):
            ListeningComprehensionPage(viewModel: ListeningComprehensionPageViewModelImpl(prompt: prompt))
        case .conversationSimulationPage(let prompt):
            ConversationSimulationPage(viewModel: ConversationSimulationPageViewModelImpl(prompt: prompt))
        case .writingTaskPage(let prompt):
            WritingTaskPage()
        case .map:
            ScavengerHuntMap(viewModel: ScavengerHuntMapViewModelImpl(router: self, scavengerHunt: scavengerHunt))
        }
    }
}
