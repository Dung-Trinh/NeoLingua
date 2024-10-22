import SwiftUI

struct EducationalGamesPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel = EducationalGamesPageViewModelImpl()
    
    var body: some View {
        VStack(alignment: .center) {
            Text("EducationalGamesPage").font(.title)
            PrimaryButton(
                title: "SnapVocabulary",
                color: .blue,
                action: {
                    router.push(.snapVocabularyPage)
                }
            )
            PrimaryButton(
                title: "LinguaQuest",
                color: .blue,
                action: {
                    router.push(.linguaQuestPage)
                }
            )
        }
        .padding()
        .navigationDestination(for: Route.self) { route in
            router.destination(for: route)
        }
    }
}
