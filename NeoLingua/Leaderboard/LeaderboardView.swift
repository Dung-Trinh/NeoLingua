import SwiftUI

struct LeaderboardView: View {
    @State var scavengerHunt: ScavengerHunt? = nil
    @State var userScores: [UserScore] = []
    
    var body: some View {
        ScrollView {
            VStack {
                if let scavengerHunt = scavengerHunt {
                    Text(scavengerHunt.title).bold()
                    ForEach(scavengerHunt.taskLocations) { location in
                        Label(location.name, systemImage: "mappin.and.ellipse")
                    }
                }
                HStack {
                    Text("Platz")
                        .font(.headline)
                        .frame(width: 50, alignment: .leading)
                    Text("Name")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Punkte")
                        .font(.headline)
                        .frame(width: 80, alignment: .trailing)
                }
                .padding(.vertical, Styleguide.Margin.extraSmall)
                .background(Color(.systemGray6))
                ForEach(0..<userScores.count) { index in
                    LeaderboardTile(
                        rank: "\(index + 1).",
                        username: userScores[index].username,
                        score: String(format: "%.2f", userScores[index].totalPoints)
                    )
                }
            }
        }.padding()
    }
}
