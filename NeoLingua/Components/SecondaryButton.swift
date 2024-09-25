import SwiftUI

public struct SecondaryButton: View {
    let title: String
    let color: Color
    let action: () -> Void?
    
    public var body: some View {
        HStack {
            Button {
                action()
            } label: {
                Text(title)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(color)
                    .background(
                        RoundedRectangle(
                            cornerRadius: 20,
                            style: .continuous
                        )
                        .stroke(color, lineWidth: 2)
                    )
            }
        }
    }
}
