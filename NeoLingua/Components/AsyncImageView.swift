import SwiftUI

struct AsyncImageView: View {
    let imageUrl: String
    
    var body: some View {
        if let url = URL(string: imageUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    Image(systemName: "xmark.circle")
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: .infinity, height: 400)
            .cornerRadius(10)
        } else {
            Text("Invalid URL")
        }
    }
}
