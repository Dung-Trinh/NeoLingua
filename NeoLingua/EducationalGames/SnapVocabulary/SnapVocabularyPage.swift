import SwiftUI

struct SnapVocabularyPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel = SnapVocabularyPageViewModelImpl()
    var body: some View {
        VStack {
            PageHeader(
                title: "SnapVocabulary",
                subtitle: "decription of the game..."
            )
            PrimaryButton(
                title: "Foto hochladen und Übungen dazu machen",
                color: .blue,
                action: {
                    router.push(.imageBasedLearningPage)
                }
            )
            PrimaryButton(
                title: "Suche nach Lerninhalten in der Umgebung",
                color: .blue,
                action: {
                    router.push(.imageBasedTaskNearMePage)
                }
            )
            
            PageHeader(
                title: "Schnitzeljagd",
                subtitle: "decription of the game..."
            )
            PrimaryButton(
                title: "Schnitzeljagd in der Umgebung generieren",
                color: .blue,
                action: {
                    router.push(.scavengerHunt(.scavengerHunt(.generatedNearMe)))
                }
            )
            
            PrimaryButton(
                title: "Schnitzeljagd in der Umgebung suchen",
                color: .blue,
                action: {
                    router.push(.scavengerHunt(.scavengerHunt(.locationBased)))
                }
            )
        }
        .padding()
        .navigationDestination(for: Route.self) { route in
            router.destination(for: route)
        }
    }
}
