import SwiftUI

struct OnboardingPage<ViewModel>: View where ViewModel: OnboardingPageViewModel {
    @StateObject var viewModel: ViewModel
    @EnvironmentObject private var router: Router
    
    var body: some View {
        NavigationStack(
            path: $router.routes
        ) {
            VStack(alignment: .center) {
                Text("Sprachen lernen mit").font(.title).bold()
                Text("NeoLingua").font(.title).bold().padding(.bottom, 100)
                Image("guyTalkingToBot").resizable().frame(height: 300).scaledToFit()
                Spacer()
                buttonContainer
            }
            .padding()
            .task {
                await viewModel.loadContent()
            }.navigationDestination(for: Route.self) { route in
                router.destination(for: route)
            }
            .navigationBarHidden(true)
        }
    }
    
    private var buttonContainer: some View {
        VStack(spacing: Styleguide.Margin.medium) {
            SecondaryButton(
                title: "Registrieren",
                color: .blue,
                action: {
                    viewModel.navigateTo(.signup)
                }
            )
            PrimaryButton(
                title: "Anmelden",
                color: .blue,
                action: {
                    viewModel.navigateTo(.login)
                }
            )
        }
    }
}
