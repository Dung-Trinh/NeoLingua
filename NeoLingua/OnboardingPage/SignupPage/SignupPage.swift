import Foundation
import SwiftUI

struct SignupPage<ViewModel>: View where ViewModel: SignupPageViewModel {
    @StateObject var viewModel: ViewModel
    @EnvironmentObject private var router: Router

    var body: some View {
        VStack {
            PageHeader(
                title: "Erstelle ein Account",
                subtitle: "Geben Sie ihre Daten ein."
            )
            VStack(spacing: Styleguide.Margin.medium) {
                emailInputField
                passwordInputField
                PrimaryButton(
                    title: "Registrieren",
                    color: .blue,
                    action: {
                        Task {
                            await viewModel.didTapSignup()
                        }
                    }
                )
//                HStack {
//                    dividerLine
//                    Text("OR").foregroundColor(.gray)
//                    dividerLine
//                }
//                PrimaryButton(
//                    title: "Sign up with Google",
//                    color: .gray.opacity(0.8),
//                    image: Image("googleLogo"),
//                    action: {
//                        Task {
//                            await viewModel.handleSignupWithGoogle(viewController: getRootViewController())
//                        }
//                    }
//                )
            }.padding(.bottom, Styleguide.Margin.medium)
            Spacer()
            HStack {
                Text("Hast du schon ein Account?").foregroundColor(.gray)
                Button {
                    viewModel.didTapLogin()
                } label: {
                    Text("Jetzt anmelden").foregroundColor(.black)
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
            placeholderText: "Passwort",
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
