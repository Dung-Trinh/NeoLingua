import SwiftUI

struct SignupUserDataPage<ViewModel>: View where ViewModel: SignupUserDataPageViewModel {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Text("SignupUserDataPage")
            nameInputField
            Spacer()
            Button("speichern") {
                Task {
                    await viewModel.saveUserData()
                }
            }
        }
    }
    
    @ViewBuilder
    private var nameInputField: some View {
        BasicInputField(
            input: $viewModel.name,
            title: "Name",
            placeholderText: "Name",
            iconName: "person.fill",
            isSecurityField: false
        )
    }
}
