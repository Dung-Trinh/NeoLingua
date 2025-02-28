import SwiftUI

struct ScavengerHuntHelpView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image("scavengerHuntHelpImage")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                Text("How it works:").font(.title).bold()
                VStack(alignment: .leading, spacing: Styleguide.Margin.small) {
                    Text("**1. Discover locations:** Check out the list of available locations in the overview.")
                    Text("**2. Switch to the map:** Use the 'Show playing field' button to see the locations on the map.")
                    Text("**3. Move to the location:** Get closer to a location to unlock and start the tasks.")
                    Text("**4. Complete the tasks:** Once you're close enough, solve the tasks and get points!")
                }
                .font(.body)
            }
            .padding()
            .navigationTitle("Instruction")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
