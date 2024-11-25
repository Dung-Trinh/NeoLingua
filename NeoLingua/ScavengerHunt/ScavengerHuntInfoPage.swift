import SwiftUI

struct ScavengerHuntInfoPage: View {
    @EnvironmentObject private var router: Router
    
    var body: some View {
        VStack {
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
                    router.push(.scavengerHunt(.scavengerHunt(.competitiveMode)))
                }
            )
        }.padding()
    }
}
