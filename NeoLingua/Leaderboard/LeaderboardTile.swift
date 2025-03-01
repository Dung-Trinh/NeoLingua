import SwiftUI

struct LeaderboardTile: View {
    let rank: String
    let username: String
    let score: String
    
    var body: some View {
        HStack {
            Text(rank)
                .font(.headline)
                .frame(width: 50, alignment: .leading)
            Image(systemName:"person.crop.circle.fill")
                .resizable()
                .scaledToFill()
                .frame(width: 30, height: 30)
                .clipShape(Circle())
            Text(username)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(score)
                .font(.subheadline)
                .frame(width: 80, alignment: .trailing)
        }.padding(.vertical, Styleguide.Margin.small)
    }
}
