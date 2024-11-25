import SwiftUI

struct EducationalGamesPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel = EducationalGamesPageViewModelImpl()
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Educational Games").font(.title).bold()
            ScrollView {
                EducationalGameTile(image: "vocabularyImage", title: "SnapVocabulary")
                    .onTapGesture {
                        router.push(.snapVocabularyPage)
                    }
                EducationalGameTile(image: "scavengerHuntImage", title: "ScavengerHunt")
                    .onTapGesture {
                        router.push(.scavengerHuntInfoPage)
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(16)
            }
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.black)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}
