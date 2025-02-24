import SwiftUI

struct EducationalGamesPage<ViewModel>: View where ViewModel: EducationalGamesPageViewModel {
    @StateObject var viewModel: ViewModel
    @EnvironmentObject private var router: Router
    
    var body: some View {
        VStack {
            Text("Educational Games").font(.title).bold()
            ScrollView(showsIndicators: false) {
                VStack(spacing: Styleguide.Margin.medium) {
                    EducationalGameTile(image: "contextBasedLearning", title: "Kontextbasiertes Lernen") {
                        viewModel.navigateTo(.contextBasedLearning)
                    }
                    EducationalGameTile(image: "vocabularyImage", title: "SnapVocabulary") {
                        viewModel.navigateTo(.snapVocabulary)
                    }
                    EducationalGameTile(image: "scavengerHuntHelpImage", title: "Schnitzeljagd") {
                        viewModel.navigateTo(.scavengerHunt)
                    }
                }
            }
            Spacer()
        }
        .padding()
        .navigationDestination(for: Route.self) { route in
            router.destination(for: route)
        }
    }
}
