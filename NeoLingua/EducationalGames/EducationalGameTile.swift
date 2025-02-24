import SwiftUI

struct EducationalGameTile: View {
    var image: String
    var title: String
    let action: () -> Void
    let blueColor = Color(red: 48 / 255.0, green: 70 / 255.0, blue: 116 / 255.0)
    
    var body: some View {
        VStack(alignment: .center, spacing: Styleguide.Margin.extraSmall) {
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
