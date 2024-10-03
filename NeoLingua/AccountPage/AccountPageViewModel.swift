import Foundation
protocol AccountPageViewModel: ObservableObject {
    var profileData: ProfileData? { get }
    
    func setupRouter(_ router: RouterImpl)
    func didTappedLogout()
    func fetchProfileData() async
}

class AccountPageViewModelImpl: AccountPageViewModel {
    private var router: RouterImpl?
    @Published var profileData: ProfileData?
    
    func setupRouter(_ router: RouterImpl) {
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
    }
}
