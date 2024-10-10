import SwiftUI

struct ScavengerHuntOverviewPage: View {
    @EnvironmentObject private var router: Router

    var body: some View {
        VStack {
            Button("Spielfeld anzeigen") {
                router.push(.scavengerHunt(.map))
            }
        }.navigationDestination(for: Route.self) { route in
            router.destination(for: route)
        }
    }
}
