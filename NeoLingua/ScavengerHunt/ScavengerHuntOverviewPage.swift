import SwiftUI

struct ScavengerHuntOverviewPage: View {
    @EnvironmentObject private var router: Router
    @StateObject private var viewModel = ScavengerHuntOverviewPageViewModelImpl()
    
    var body: some View {
        VStack {
            Button("Spielfeld anzeigen") {
                router.push(.scavengerHunt(.map))
            }
            
            Button("Vokabelübung starten") {
                router.push(.learningTask(.vocabularyTrainingPage))
            }

        }.navigationDestination(for: Route.self) { route in
            router.destination(for: route)
        }
    }
}
