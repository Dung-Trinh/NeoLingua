import SwiftUI

struct OnboardingPage<ViewModel>: View where ViewModel: OnboardingPageViewModel {
    @StateObject var viewModel: ViewModel
    @EnvironmentObject private var router: Router
    
    var body: some View {
        NavigationStack(
            path: $router.routes
        ) {
            VStack(alignment: .center) {
                TabView {
                    ForEach(viewModel.carouselContent) { content in
                        //CarouselView(content: content)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
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
                title: "Sign up",
                color: Styleguide.PrimaryColor.purple,
                action: {
                    router.push(.loginSignup(.signup))
                }
            )
            PrimaryButton(
                title: "Login",
                color: Styleguide.PrimaryColor.purple,
                action: {
                    router.push(.loginSignup(.login))
                }
            )
        }
    }
}
