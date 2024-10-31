import SwiftUI

struct ScavengerHuntOverviewPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: ScavengerHuntOverviewPageViewModelImpl
    @State var initialAppearance = false
    
    var body: some View {
        ScrollView {
            VStack {
                if let currentScavengerHunt = viewModel.currentScavengerHunt {
                    PageHeader(
                        title: "ScavengerHunt",
                        subtitle: currentScavengerHunt.introduction
                    )
                    Text("Location")
                    if let scavengerHunt = viewModel.currentScavengerHunt {
                        ForEach(scavengerHunt.taskLocations) { location in
                            Label(location.name, systemImage: "mappin.and.ellipse")
                        }
                        VStack {
                            Button(action: {
                                if let scavengerHunt = viewModel.currentScavengerHunt {
                                    router.scavengerHunt = scavengerHunt
                                }
                                router.push(.learningTask(.map))
                            }, label: {
                                Label("Show playing field", systemImage: "map.fill")
                            })
                        }
                        
                        if scavengerHunt.isHuntComplete() {
                            Button("show final result") {
                                
                            }
                        }
                    }
                    
                }
            }.onAppear {
                Task {
                    if initialAppearance == false {
                        await viewModel.fetchScavengerHunt()
                        initialAppearance = true
                    } else {
                        await viewModel.updateScavengerHuntState()
                    }
                }
            }
        }.navigationDestination(for: Route.self) { route in
            router.destination(for: route)
        }
    }
}
