import SwiftUI

struct LoginPage<ViewModel>: View where ViewModel: LoginPageViewModel {
    @StateObject var viewModel: ViewModel
    @EnvironmentObject var router: RouterImpl
    
    var body: some View {
        VStack {
            PageHeader(
                title: "Log in",
                subtitle: "Please enter your data."
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
                    title: "Login",
                    color: Styleguide.PrimaryColor.purple,
                    action: {
                        Task {
                            await viewModel.didTappedLogin()
                        }
                    }
                )
                HStack {
                    dividerLine
                    Text("OR").foregroundColor(.gray)
                    dividerLine
                }
                PrimaryButton(
                    title: "Log in with Google",
                    color: .gray.opacity(0.8),
                    image: Image("googleLogo"),
                    action: {
                        Task {
                            await viewModel.handleSignInButton(viewController: getRootViewController())
                        }
                    }
                )
            }
            
            Spacer()
            HStack {
                Text("Don't have an account?").foregroundColor(.gray)
                Button {
                    router.pushView(view: .signupPage)
                } label: {
                    Text("Sign up").foregroundColor(.black)
                }
            }
        }
        .padding()
        .onAppear{
            viewModel.setupRouter(router)
        }
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

#Preview {
    LoginPage(
        viewModel: LoginPageViewModelImpl(loginAdapter: LoginSignupNetworkAdapterImpl())
    )
}
