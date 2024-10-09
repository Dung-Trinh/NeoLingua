import SwiftUI

struct AccountPage<ViewModel>: View where ViewModel: AccountPageViewModel {
    @StateObject var viewModel: ViewModel
    @EnvironmentObject private var router: Router

    var body: some View {
        VStack {
            Text("AccountPage")
            if let profileData = viewModel.profileData {
                VStack {
                    HStack {
                        Text("Name:").bold()
                        Text(profileData.name)
                    }
                    HStack {
                        Text("tägliches Ziel:").bold()
                        Text(profileData.estimationOfDailyUse.description)
                    }
                    HStack {
                        Text("Lernziele:").bold()
                        Text(profileData.learningGoals.description)
                    }
                    HStack {
                        Text("Lernziele:").bold()
                        Text(profileData.interests.description)
                    }
                    
                }
            }
            Spacer()
            Button("Logout") {
                viewModel.didTappedLogout()
            }
        }.onAppear {
            Task {
                await viewModel.fetchProfileData()
            }
        }
        .navigationDestination(for: Route.self) { route in
            router.destination(for: route)
        }
    }
}
