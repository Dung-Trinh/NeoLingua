import SwiftUI

struct EducationalGamesPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel = EducationalGamesPageViewModelImpl()
    
    var body: some View {
        VStack {
            Text("Educational Games").font(.title).bold()
            ScrollView {
                VStack(spacing: 16) {
                    EducationalGameTile(image: "vocabularyImage", title: "Context-based-tasks") {
                        router.push(.imageBasedLearningPage)
                    }
                    EducationalGameTile(image: "vocabularyImage", title: "SnapVocabulary") {
                        router.push(.imageBasedTaskNearMePage)
                    }.frame(width: .infinity)
                    EducationalGameTile(image: "scavengerHuntImage", title: "ScavengerHunt") {
                        router.push(.scavengerHuntInfoPage)
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

struct EducationalGameTile: View {
    var image: String
    var title: String
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Button(action: {
                action()
            }, label: {
                VStack {
                    Image(image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: .infinity, height: 150)
                        .clipped()
                        .cornerRadius(16)
                    
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.black)
                .cornerRadius(16)
                .frame(width: .infinity)
            })
            
        }
    }
}
