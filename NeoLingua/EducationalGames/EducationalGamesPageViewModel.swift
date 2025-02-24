import Foundation

enum EducationalGamesPageDestination {
    case contextBasedLearning
    case snapVocabulary
    case scavengerHunt
}

protocol EducationalGamesPageViewModel: ObservableObject {
    func navigateTo(_ destination: EducationalGamesPageDestination)
}

class EducationalGamesPageViewModelImpl: EducationalGamesPageViewModel {
    @Published private var router: Router
    
    init(router: Router) {
        self.router = router
    }
    
    func navigateTo(_ destination: EducationalGamesPageDestination) {
        switch destination {
        case .contextBasedLearning:
            router.push(.contexBasedLearningPage)
        case .snapVocabulary:
            router.push(.snapVocabularyPage)
        case .scavengerHunt:
            router.push(.scavengerHuntInfoPage)
        }
    }
}
