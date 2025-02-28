import Foundation
import Combine

protocol AccountPageViewModel: ObservableObject {
    var profileData: ProfileData? { get }
    var selectedLevel: LevelOfLanguage { get set }
    var selectedDailyUseTime: Int { get set }
    var isLoading: Bool { get set }
    var estimationOfDailyUseTime: [Int] { get }

    func didTappedLogout()
    func fetchProfileData() async
}

class AccountPageViewModelImpl: AccountPageViewModel {
    private var anyCancellables = Set<AnyCancellable>()
    private let userDataManager = UserDataManagerImpl()
    let estimationOfDailyUseTime: [Int] = [5,10,15,30,60]

    @Published var profileData: ProfileData?
    @Published var router: Router
    @Published var selectedLevel: LevelOfLanguage = .A1
    @Published var selectedDailyUseTime: Int = 0
    @Published var isLoading: Bool = false
    
    init(router: Router) {
        self.router = router
        
        $selectedLevel.sink(receiveValue: { value in
            UserDefaults.standard.setLevelOfLanguage(value)
            print("$selectedLevel")
            print(value)
        }).store(in: &anyCancellables)
    }
    
    func fetchProfileData() async {
        isLoading = true
        defer { isLoading = false }
        
        print("fetchProfileData")
        
        do {
            let data = try await userDataManager.fetchUserData()
            profileData = data
            selectedDailyUseTime = data.estimationOfDailyUse
        } catch {
            print("fetchProfileData err")
        }
    }
    
    func didTappedLogout() {
        UserDefaults.standard.setUserLoggedIn(false)
        router.push(.onboardingPage)
    }
}
