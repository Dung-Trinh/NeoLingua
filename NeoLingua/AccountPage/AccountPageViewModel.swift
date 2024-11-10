import Foundation
import Combine

protocol AccountPageViewModel: ObservableObject {
    var profileData: ProfileData? { get }
    var selectedLevel: LevelOfLanguage { get set }
    
    func didTappedLogout()
    func fetchProfileData() async
}

class AccountPageViewModelImpl: AccountPageViewModel {
    @Published var profileData: ProfileData?
    @Published var router: Router
    @Published var selectedLevel: LevelOfLanguage = .A1
    private var anyCancellables = Set<AnyCancellable>()

    init(router: Router) {
        self.router = router
        
        $selectedLevel.sink(receiveValue: { value in
            UserDefaults.standard.setLevelOfLanguage(value)
            print("$selectedLevel")
            print(value)
        }).store(in: &anyCancellables)
    }
    
    func fetchProfileData() async {
        print("fetchProfileData")
        let userDataManager = UserDataManagerImpl()
        
        do {
            let data = try await userDataManager.fetchUserData()
            profileData = data
        } catch {
            print("fetchProfileData err")
        }
    }
    
    func didTappedLogout() {
        UserDefaults.standard.setUserLoggedIn(false)
        router.push(.onboardingPage)
    }
}
