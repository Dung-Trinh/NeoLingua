import SwiftUI

struct ScavengerHuntOverviewPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: ScavengerHuntOverviewPageViewModelImpl
    
    var body: some View {
        ScrollView {
            VStack {
                if let currentScavengerHunt = viewModel.currentScavengerHunt {
                    PageHeader(
                        title: "ScavengerHunt",
                        subtitle: currentScavengerHunt.introduction
                    )
                    
                    Text("Location")
                    VStack {
                        if let scavengerHunt = viewModel.currentScavengerHunt {
                            Button(action: {
                                if let scavengerHunt = viewModel.currentScavengerHunt {
                                    router.scavengerHunt = scavengerHunt
                                }
                                router.push(.learningTask(.map))
                            }, label: {
                                Label("Show playing field", systemImage: "map.fill")
                            })
                        }
                    }
                }
            }.onAppear {
                Task {
                    await viewModel.fetchScavengerHunt()
                }
            }
        }.navigationDestination(for: Route.self) { route in
            router.destination(for: route)
        }
    }
}
