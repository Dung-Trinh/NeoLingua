import SwiftUI

struct LinguaQuestPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel = LinguaQuestPageViewModelImpl()
    
    var body: some View {
        VStack {
            PageHeader(
                title: "LinguaQuest",
                subtitle: "decription of the game..."
            )

        }.navigationDestination(for: Route.self) { route in
            router.destination(for: route)
        }
    }
}
