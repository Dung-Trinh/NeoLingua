import Foundation
import SwiftUI

struct SignupPage<ViewModel>: View where ViewModel: SignupPageViewModel {
    @StateObject var viewModel: ViewModel
    @EnvironmentObject private var router: Router

    var body: some View {
        VStack {
            PageHeader(
                title: "Create an account",
                subtitle: "Please enter your data."
            )
            VStack(spacing: Styleguide.Margin.medium) {
                nameInputField
                emailInputField
                passwordInputField
                PrimaryButton(
                    title: "Sign up",
                    color: Styleguide.PrimaryColor.purple,
                    action: {
                        Task {
                            await viewModel.didTapSignup()
                        }
                    }
                )
                HStack {
                    dividerLine
                    Text("OR").foregroundColor(.gray)
                    dividerLine
                }
                PrimaryButton(
                    title: "Sign up with Google",
                    color: .gray.opacity(0.8),
                    image: Image("googleLogo"),
                    action: {
                        Task {
                            await viewModel.handleSignupWithGoogle(viewController: getRootViewController())
                        }
                    }
                )
            }.padding(.bottom, Styleguide.Margin.medium)
            Spacer()
            HStack {
                Text("Already have an account?").foregroundColor(.gray)
                Button {
                    viewModel.didTapLogin()
                } label: {
                    Text("Log in").foregroundColor(.black)
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
    private var nameInputField: some View {
        BasicInputField(
            input: $viewModel.name,
            title: "Name",
            placeholderText: "Name",
            iconName: "person.fill",
            isSecurityField: false
        )
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
            title: "Password",
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
