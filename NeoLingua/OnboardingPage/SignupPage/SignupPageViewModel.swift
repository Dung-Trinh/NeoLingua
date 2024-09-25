import Foundation
import UIKit

protocol SignupPageViewModel: ObservableObject {
    var name: String { get set }
    var email: String { get set }
    var password: String { get set }
    
    func setupRouter(_ router: RouterImpl)
    func didTapSignup() async
    func didTapLogin()
    func handleSignupWithGoogle(viewController: UIViewController) async
}

class SignupPageViewModelImpl: SignupPageViewModel {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    
    private let loginAdapter: LoginSignupNetworkAdapter
    private var router: RouterImpl?
    
    init(loginAdapter: LoginSignupNetworkAdapter) {
        self.loginAdapter = loginAdapter
    }
    
    convenience init() {
        self.init(loginAdapter: LoginSignupNetworkAdapterImpl())
    }
    
    func setupRouter(_ router: RouterImpl) {
        self.router = router
    }
    
    func didTapSignup() async {
        do {
            try await loginAdapter.createUser(email: email, password: password)
        } catch let err {
            // TODO: adding error handling
            print(err.localizedDescription)
        }
    }
    
    @MainActor
    func didTapLogin() {
        router?.pushView(view: .loginPage)
    }
    
    func handleSignupWithGoogle(viewController: UIViewController) async {
        do {
            try await loginAdapter.signupWithGoogle(viewController: viewController)
        } catch let err {
            print(err.localizedDescription)
        }
    }
}
