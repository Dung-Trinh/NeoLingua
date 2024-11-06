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
                        Text("Username:").bold()
                        Text(profileData.username)
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
                    Text("Sprachniveau")
                }
            }
            Picker("", selection: $viewModel.selectedLevel){
                ForEach(LevelOfLanguage.allCases) { level in
                    Text(level.rawValue).tag(level)
                }
            }
            .pickerStyle(.segmented)
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

