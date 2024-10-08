import Foundation
import UIKit

protocol SignupPageViewModel: ObservableObject {
    var name: String { get set }
    var email: String { get set }
    var password: String { get set }
    
    func didTapSignup() async
    func didTapLogin()
    func handleSignupWithGoogle(viewController: UIViewController) async
}

class SignupPageViewModelImpl: SignupPageViewModel {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var router: Router

    private let loginAdapter: LoginSignupNetworkAdapter
    
    init(
        router: Router,
        loginAdapter: LoginSignupNetworkAdapter
    ) {
        self.loginAdapter = loginAdapter
        self.router = router
    }
    
    convenience init(router: Router) {
        self.init(
            router: router,
            loginAdapter: LoginSignupNetworkAdapterImpl()
        )
    }
    
    func didTapSignup() async {
        do {
            try await loginAdapter.createUser(email: email, password: password)
            router.push(.loginSignup(.login))
            
        } catch let err {
            // TODO: adding error handling
            print(err.localizedDescription)
        }
    }
    
    @MainActor
    func didTapLogin() {
        router.push(.loginSignup(.login))
    }
    
    func handleSignupWithGoogle(viewController: UIViewController) async {
        do {
            try await loginAdapter.signupWithGoogle(viewController: viewController)
        } catch let err {
            print(err.localizedDescription)
        }
    }
}
