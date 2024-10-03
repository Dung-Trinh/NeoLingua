import SwiftUI

struct AccountPage<ViewModel>: View where ViewModel: AccountPageViewModel {
    @StateObject var viewModel: ViewModel
    
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
                    
                }
            }
            Spacer()
            Button("Logout") {
                viewModel.didTappedLogout()
            }
        }.onAppear(perform: {
            Task {
                await viewModel.fetchProfileData()
            }
        })
    }
}
