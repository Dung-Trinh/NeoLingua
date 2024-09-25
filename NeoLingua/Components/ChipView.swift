import SwiftUI

struct ChipView: View {
    var body: some View {
        HStack(spacing: Styleguide.Margin.small) {
            Text("test")
                .font(.system(size: 12))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(Styleguide.Margin.extraSmall)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.blue).opacity(0.5)
                )
        }
    }
}
