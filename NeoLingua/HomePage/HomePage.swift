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
                ChallengePage()
                    .tabItem {
                        Label("Challenges", systemImage: "list.bullet.clipboard.fill")
                    }
                UserStatsDashboardPage(viewModel: UserStatsDashboardPageViewModellImpl())
                    .tabItem {
                        Label("User Stats", systemImage: "chart.xyaxis.line")
                    }
                LeaderboardPage(viewModel: LeaderboardPageViewModelImpl())
                    .tabItem {
                        Label("Leaderboard", systemImage: "trophy.fill")
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
