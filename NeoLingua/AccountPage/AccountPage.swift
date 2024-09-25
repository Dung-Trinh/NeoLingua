import SwiftUI

struct AccountPage<ViewModel>: View where ViewModel: AccountPageViewModel {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Text("AccountPage")
            Spacer()
            Button("Logout") {
                viewModel.didTappedLogout()
            }
        }
    }
}
