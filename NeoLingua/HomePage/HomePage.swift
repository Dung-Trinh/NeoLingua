import SwiftUI

struct HomePage<ViewModel>: View where ViewModel: HomePageViewModel {
    @StateObject var viewModel: ViewModel
    @EnvironmentObject private var router: Router
    
    var body: some View {
        NavigationStack(
            path: $router.routes
        ) {
            TabView {
                EducationalGamesPage(viewModel: EducationalGamesPageViewModelImpl(router: router))
                    .tabItem {
                        Label("Learning", systemImage: "books.vertical.fill")
                    }
                ChallengePage(viewModel: ChallengePageViewModellImpl())
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
