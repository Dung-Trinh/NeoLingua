import SwiftUI

struct SignupUserDataPage<ViewModel>: View where ViewModel: SignupUserDataPageViewModel {
    @StateObject var viewModel: ViewModel
    @EnvironmentObject private var router: Router

    var body: some View {
        VStack(spacing: Styleguide.Margin.small) {
            Text("Persöhnliche Daten")
            usernameInputField
            interestInputField
            Spacer()
            PrimaryButton(
                title: "Weiter",
                color: .blue,
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
            title: "Benutzername",
            placeholderText: "Benutzername",
            iconName: "person.fill",
            isSecurityField: false
        )
    }
    
    @ViewBuilder
    private var interestInputField: some View {
        VStack {
            BasicInputField(
                input: $viewModel.interestsInputText,
                title: "Interessen",
                placeholderText: "lesen, malen, Serien schauen",
                iconName: "eyes",
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
            Picker("", selection: $viewModel.estimationOfDailyUse) {
                ForEach(viewModel.estimationOfDailyUseTime, id: \.self) {
                    Text($0.description)
                }
            }.pickerStyle(.segmented)
        }
    }
}
