import SwiftUI

struct HomePage<ViewModel>: View where ViewModel: HomePageViewModel {
    @StateObject var viewModel: ViewModel
    @EnvironmentObject private var router: Router
    
    
    var body: some View {
        // TODO: fix nav bug
        NavigationStack(
            path: $router.routes
        ) {
            TabView {
                EducationalGamesPage()
                    .tabItem {
                        Label("Learning", systemImage: "books.vertical.fill")
                    }
                LearningOverviewPage(viewModel: LearningOverviewPageViewImpl())
                    .tabItem {
                        Label("Learning", systemImage: "person.crop.circle.fill")
                    }
                ContextAwarePage(viewModel: ContextAwarePageViewModelImpl())
                    .tabItem {
                        Label("Learning", systemImage: "person.crop.circle.fill")
                    }

                AccountPage(viewModel: AccountPageViewModelImpl(router: router))
                    .tabItem {
                        Label("Account", systemImage: "person.crop.circle.fill")
                    }
            }
        }
        .navigationBarHidden(true)
    }
}
