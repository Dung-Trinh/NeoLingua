import SwiftUI

struct LeaderboardPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: LeaderboardPageViewModelImpl
    
    var body: some View {
        VStack {
            Text("ScavengerHunt LeaderBoard")
        }
    }
}
