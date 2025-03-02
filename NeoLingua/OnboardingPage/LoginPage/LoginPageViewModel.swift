import Foundation
import SwiftUI
import FirebaseCore
//import GoogleSignIn
import FirebaseAuth

protocol LoginPageViewModel: ObservableObject {
    var email: String { get set }
    var password: String { get set }
    var errorMessage: String? { get }
    var isLoading: Bool { get }
    
    func didTappedLogin() async
    func handleSignInButton(viewController: UIViewController) async
}

class LoginPageViewModelImpl: LoginPageViewModel {
    private var router: Router
    private let loginAdapter: LoginSignupNetworkAdapter
    
    @Published var email = ProdENV().USER_NAME
    @Published var password = ProdENV().USER_PASSWORD
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
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
    
    @MainActor
    func didTappedLogin() async {
        validateInput()
        
        do {
            isLoading = true
            defer { isLoading = false }
            try await loginAdapter.login(email: email, password: password)
            router.push(.homePage)
        } catch let err {
            print(err)
            errorMessage = err.localizedDescription
        }
    }
    
    func handleSignInButton(viewController: UIViewController) async {
        do {
            try await loginAdapter.loginWithGoogle(viewController: viewController)
            router.push(.homePage)
        } catch {
            // TODO: error handling
        }
    }
    
    private func validateInput() {
        // TODO: add email and password validation
    }
}
