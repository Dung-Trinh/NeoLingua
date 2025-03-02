import SwiftUI

enum ScavengerHuntType: Hashable {
    case generatedNearMe(Int, Int)
    case competitiveMode
}

enum ScavengerHuntRoute: Hashable {
    case taskLocation
    case scavengerHunt(ScavengerHuntType)
}

enum LearningTaskRoute: Hashable {
    case map
    case vocabularyTrainingPage(prompt: String, isScavengerHuntMode: Bool = false)
    case listeningComprehensionPage(prompt: String, isScavengerHuntMode: Bool = false)
    case conversationSimulationPage(prompt: String, isScavengerHuntMode: Bool = false)
}

enum Route: Hashable {
    
    case loginSignup(LoginSignupRoute)
    case scavengerHunt(ScavengerHuntRoute)
    case learningTask(LearningTaskRoute)
    case homePage
    case onboardingPage
    case taskLocation
    case contexBasedLearningPage
    case snapVocabularyPage
    case scavengerHuntInfoPage
    case shareImageForTaskPage(SharedContentForTask)
    case contextBasedLearning(LearningTaskRoute)
    
    enum LoginSignupRoute: Hashable {
        case login
        case signup
        case signupData
        case successfullyRegistered
    }
    

}
//@Observable
class Router: ObservableObject  {
    @Published var routes: [Route] = []
    
    var taskLocation: TaskLocation? = nil
    var scavengerHunt: ScavengerHunt? = nil
    
    private let startEmptyStackViews: [Route] = [
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
            OnboardingPage(viewModel: OnboardingPageViewModelImpl(adapter: OnboardingNetworkAdapterImpl(), router: self))
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
        case .contexBasedLearningPage:
            ContexBasedLearningPage(viewModel: ContextBasedLearningPageViewModelImpl(router: self))
        case .snapVocabularyPage:
            SnapVocabularyPage(viewModel: SnapVocabularyPageViewModelImpl())
        case .contextBasedLearning(let taskRoute):
            handleLearningTaskRoute(taskRoute)
        case .shareImageForTaskPage(let sharedContentForTask):
            ShareImageForTaskPage(viewModel: ShareImageForTaskPageViewModelImpl(sharedContentForTask: sharedContentForTask))
        case .scavengerHuntInfoPage:
            ScavengerHuntInfoPage(viewModel: ScavengerHuntInfoPageViewModelImpl(router: self))
        }
    }
    
    @ViewBuilder
    func scavengerHuntDestination(
        for route: LearningTaskRoute,
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
    
    func navigateBack() {
        routes.removeLast()
    }
    
    func navigateToRoot() {
        routes.removeLast(routes.count)
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
    private func handleScavengerHuntRoutes(_ scavengerHuntRoute: ScavengerHuntRoute) -> some View {
        switch scavengerHuntRoute {
        case .taskLocation:
            if let taskLocation = taskLocation {
                TaskLocationPage(viewModel: TaskLocationPageViewModelImpl(taskLocation: taskLocation))
            }
        case .scavengerHunt(let type):
            ScavengerHuntOverviewPage(viewModel: ScavengerHuntOverviewPageViewModelImpl(type: type))
        }
    }
    
    @ViewBuilder
    private func handleLearningTaskRoute(
        _ learningTaskRoute: LearningTaskRoute,
        scavengerHunt: ScavengerHunt
    ) -> some View {
        switch learningTaskRoute {
        case .vocabularyTrainingPage(let prompt, let isScavengerHuntMode):
            var vm: VocabularyTrainingPageViewModelImpl {
                let vm = VocabularyTrainingPageViewModelImpl(prompt: prompt, router: self)
                vm.isScavengerHuntMode = isScavengerHuntMode
                return vm
            }
            VocabularyTrainingPage(viewModel: vm)
        case .listeningComprehensionPage(let prompt, let isScavengerHuntMode):
            var vm: ListeningComprehensionPageViewModelImpl {
                let vm = ListeningComprehensionPageViewModelImpl(prompt: prompt)
                vm.isScavengerHuntMode = isScavengerHuntMode
                return vm
            }
            ListeningComprehensionPage(viewModel: vm )
        case .conversationSimulationPage(let prompt, let isScavengerHuntMode):
            var vm: ConversationSimulationPageViewModelImpl {
                let vm = ConversationSimulationPageViewModelImpl(prompt: prompt)
                vm.isScavengerHuntMode = isScavengerHuntMode
                return vm
            }
            ConversationSimulationPage(viewModel: vm)
        case .map:
            ScavengerHuntMap(viewModel: ScavengerHuntMapViewModelImpl(router: self, scavengerHunt: scavengerHunt))
        }
    }
    
    @ViewBuilder
    private func handleLearningTaskRoute(
        _ learningTaskRoute: LearningTaskRoute) -> some View {
            switch learningTaskRoute {
            case .vocabularyTrainingPage(let prompt, let isScavengerHuntMode):
                VocabularyTrainingPage(viewModel: VocabularyTrainingPageViewModelImpl(prompt: prompt, router: self))
            case .listeningComprehensionPage(let prompt, let isScavengerHuntMode):
                ListeningComprehensionPage(viewModel: ListeningComprehensionPageViewModelImpl(prompt: prompt))
            case .conversationSimulationPage(let prompt, let isScavengerHuntMode):
                ConversationSimulationPage(viewModel: ConversationSimulationPageViewModelImpl(prompt: prompt))
            case .map:
                Text("handleLearningTaskRoute error")
            }
        }
}
