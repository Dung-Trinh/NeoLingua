import SwiftUI

struct HomePage<ViewModel>: View where ViewModel: HomePageViewModel {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        TabView {
            LearningOverviewPage(viewModel: LearningOverviewPageViewImpl())
                .tabItem {
                    Label("Learning", systemImage: "person.crop.circle.fill")
                }
            ContextAwarePage(viewModel: ContextAwarePageViewModelImpl())
                .tabItem {
                    Label("Learning", systemImage: "person.crop.circle.fill")
                }
            AccountPage(viewModel: AccountPageViewModelImpl())
                .tabItem {
                    Label("Account", systemImage: "person.crop.circle.fill")
                }
        }.navigationBarHidden(true)
    }
}
