import SwiftUI

struct SignupUserDataPage<ViewModel>: View where ViewModel: SignupUserDataPageViewModel {
    @StateObject var viewModel: ViewModel
    @EnvironmentObject private var router: Router

    var body: some View {
        VStack {
            Text("SignupUserDataPage")
            usernameInputField
            goalsInputField
            Spacer()
            PrimaryButton(
                title: "Weiter",
                color: Styleguide.PrimaryColor.purple,
                action: {
                    Task {
                        await viewModel.saveUserData()
                    }
                }
            )
        }
        .padding()
        .navigationDestination(for: Route.self) { route in
            router.destination(for: route)
        }
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    private var usernameInputField: some View {
        BasicInputField(
            input: $viewModel.username,
            title: "Username",
            placeholderText: "Username",
            iconName: "person.fill",
            isSecurityField: false
        )
    }
    
    @ViewBuilder
    private var goalsInputField: some View {
        VStack {
            BasicInputField(
                input: $viewModel.interestsInputText,
                title: "Ziele",
                placeholderText: "lesen, malen, Serien schauen",
                iconName: "person.fill",
                isSecurityField: false
            )
            Text("Welche grundlegenden Sprachfähigkeiten möchten Sie verbessern?")
            HStack {
                ForEach(viewModel.vms) { vm in
                    ChipView(viewModel: vm) {
                        viewModel.didTapChipView(vm)
                    }
                }
            }
            Text("Welche sprachlichen Details möchten Sie verbessern?")
            HStack {
                ForEach(viewModel.complexSkills) { vm in
                    ChipView(viewModel: vm) {
                        viewModel.didTapChipView(vm)
                    }
                }
            }
            
            Text("Tägliches Nutzungsziel (in Minuten):")
            Picker("What is your favorite color?", selection: $viewModel.estimationOfDailyUse) {
                ForEach(viewModel.estimationOfDailyUseTime, id: \.self) {
                    Text($0.description)
                }
            }.pickerStyle(.segmented)
        }
    }
}
