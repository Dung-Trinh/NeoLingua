import SwiftUI

struct LoginPage<ViewModel>: View where ViewModel: LoginPageViewModel {
    @StateObject var viewModel: ViewModel
    @EnvironmentObject private var router: Router

    var body: some View {
        VStack {
            PageHeader(
                title: "Anmeldung",
                subtitle: "Bitte gebe deine Daten ein."
            )
            VStack(spacing: Styleguide.Margin.medium) {
                emailInputField
                passwordInputField
                if let errorMessage = viewModel.errorMessage {
                    withAnimation {
                        Text(errorMessage).foregroundColor(.red)
                    }
                }
                PrimaryButton(
                    title: "Anmelden",
                    color: .blue,
                    action: {
                        Task {
                            await viewModel.didTappedLogin()
                        }
                    }
                )
            }
            
            Spacer()
            HStack {
                Text("Hast du noch kein Account?").foregroundColor(.gray)
                Button {
                    router.push(.loginSignup(.signup))
                } label: {
                    Text("Jetzt registrieren").foregroundColor(.black)
                }
            }
        }
        .padding()
        .navigationDestination(for: Route.self) { route in
            router.destination(for: route)
        }
        .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
    }
    
    @ViewBuilder
    private var emailInputField: some View {
        BasicInputField(
            input: $viewModel.email,
            title: "Email",
            placeholderText: "Email",
            iconName: "mail"
        )
    }
    
    @ViewBuilder
    private var passwordInputField: some View {
        BasicInputField(
            input: $viewModel.password,
            title: "Passwort",
            placeholderText: "Password",
            iconName: "lock",
            isSecurityField: true
        )
    }
    
    @ViewBuilder
    private var dividerLine: some View {
        VStack {
            Divider().background(.gray)
        }
    }
}
