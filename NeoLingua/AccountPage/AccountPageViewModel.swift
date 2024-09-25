import Foundation
protocol AccountPageViewModel: ObservableObject {
    func setupRouter(_ router: RouterImpl)
    func didTappedLogout()
}

class AccountPageViewModelImpl: AccountPageViewModel {
    private var router: RouterImpl?
    
    func setupRouter(_ router: RouterImpl) {
        self.router = router
    }
    
    func didTappedLogout() {
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
    }
}
