import Foundation
import UIKit

protocol SignupPageViewModel: ObservableObject {
    var email: String { get set }
    var password: String { get set }
    var isLoading: Bool { get }
    
    func didTapSignup() async
    func didTapLogin()
    func handleSignupWithGoogle(viewController: UIViewController) async
}

class SignupPageViewModelImpl: SignupPageViewModel {
    @Published var email: String = "test@test.de"
    @Published var password: String = ""
    @Published var router: Router
    @Published var isLoading: Bool = false

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
        isLoading = true
        defer { isLoading = false }
        do {
            try await loginAdapter.createUser(email: email, password: password)
            router.push(.loginSignup(.signupData))
        } catch let err {
            print(err.localizedDescription)
        }
    }
    
    @MainActor
    func didTapLogin() {
        router.push(.loginSignup(.login))
    }
    
    func handleSignupWithGoogle(viewController: UIViewController) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await loginAdapter.signupWithGoogle(viewController: viewController)
        } catch let err {
            print(err.localizedDescription)
        }
    }
}
