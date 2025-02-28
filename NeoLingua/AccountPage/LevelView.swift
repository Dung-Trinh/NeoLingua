import SwiftUI

struct LevelView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Image(systemName: "bolt.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.blue)
                
                Text("3179 XP Punkte")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.blue)
            }
            
            ProgressView(value: 0.75)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(height: 16)
                .padding(.vertical, Styleguide.Margin.extraSmall)
            
            HStack {
                Text("LEVEL 5")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text("165 XP to")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                Text("LEVEL 6")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
