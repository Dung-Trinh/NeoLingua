import SwiftUI

struct EducationalGamesPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel = EducationalGamesPageViewModelImpl()

    var body: some View {
        VStack {
            Text("Educational Games").font(.title).bold()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    EducationalGameTile(image: "contextBasedLearning", title: "Kontextbasiertes Lernen") {
                        router.push(.contexBasedLearningPage)
                    }
                    EducationalGameTile(image: "vocabularyImage", title: "SnapVocabulary") {
                        router.push(.snapVocabularyPage)
                    }.frame(width: .infinity)
                    EducationalGameTile(image: "scavengerHuntHelpImage", title: "Schnitzeljagd") {
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
    let blueColor = Color(red: 48 / 255.0, green: 70 / 255.0, blue: 116 / 255.0)
    
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
                .background(blueColor)
                .cornerRadius(16)
                .shadow(color: blueColor.opacity(0.4), radius: 8, x: 0, y: 4)
                .frame(width: .infinity)
            })
        }
    }
}
