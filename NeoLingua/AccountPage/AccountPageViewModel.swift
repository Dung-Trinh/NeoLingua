import Foundation
protocol AccountPageViewModel: ObservableObject {
    var profileData: ProfileData? { get }
    
    func didTappedLogout()
    func fetchProfileData() async
}

class AccountPageViewModelImpl: AccountPageViewModel {
    @Published var profileData: ProfileData?
    @Published var router: Router
    
    init(router: Router) {
        self.router = router
    }
    
    func fetchProfileData() async {
        print("fetchProfileData")
        let userDataManager = UserDataManagerImpl()
        
        do {
            let data = try await userDataManager.fetchUserData()
            profileData = data
            print("fetchProfileData")
            print(data)
        } catch {
            print("fetchProfileData err")
        }
    }
    
    func didTappedLogout() {
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        router.push(.onboardingPage)
    }
}
