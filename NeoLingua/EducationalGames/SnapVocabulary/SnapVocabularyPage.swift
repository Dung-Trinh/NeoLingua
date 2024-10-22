import SwiftUI

struct SnapVocabularyPage: View {
    @StateObject var viewModel = SnapVocabularyPageViewModelImpl()
    var body: some View {
        VStack {
            PageHeader(
                title: "SnapVocabulary",
                subtitle: "decription of the game..."
            )
            PrimaryButton(
                title: "Suche nach Lerninhalten in der Umgebung",
                color: .blue,
                action: {
                   
                }
            )
            PrimaryButton(
                title: "Schnitzeljagd in der Umgebung suchen",
                color: .blue,
                action: {
                    
                }
            )
        }.padding()
    }
}
