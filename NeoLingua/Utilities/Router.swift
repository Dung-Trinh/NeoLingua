import SwiftUI

enum DestinationView: String {
    case loginPage = "LoginPage"
    case signupPage = "SignupPage"
    case homePage = "HomePage"
}

protocol Router: ObservableObject {
    var navPath: NavigationPath { get }
    
    func pushView(view: DestinationView)
}

class RouterImpl: Router {
    @Published var navPath: NavigationPath = .init()
    var childViews: [DestinationView] = []
    
    @MainActor
    func pushView(view: DestinationView) {
        navPath.append(view.rawValue)
        childViews.append(view)
    }
}
