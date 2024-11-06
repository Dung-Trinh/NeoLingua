import SwiftUI

struct LeaderboardPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: LeaderboardPageViewModelImpl
    
    var body: some View {
        VStack {
            Text("LeaderboardPage")
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
            .padding(.vertical, 4)
            .background(Color(.systemGray6))
            ForEach(Array(viewModel.userScores.enumerated()), id: \.element.id) { index, userScore in
                HStack {
                    Text("\(index + 1).")
                        .font(.headline)
                        .frame(width: 50, alignment: .leading)
                    Text(userScore.username)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(String(format: "%.2f", userScore.points))
                        .font(.subheadline)
                        .frame(width: 80, alignment: .trailing)
                }
                .padding(.vertical, 8)
            }
        }
        .padding()
        .onAppear {
            Task {
                await viewModel.fetchUserScores()
            }
        }
    }
}
