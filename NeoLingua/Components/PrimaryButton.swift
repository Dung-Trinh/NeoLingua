import SwiftUI

public struct PrimaryButton: View {
    let title: String
    let color: Color
    let image: Image?
    let action: () -> Void?
    
    init(
        title: String,
        color: Color,
        image: Image? = nil,
        action: @escaping () -> Void?
    ) {
        self.title = title
        self.color = color
        self.image = image
        self.action = action
    }
    
    public var body: some View {
        HStack(alignment: .center) {
            Button {
                action()
            } label: {
                HStack(alignment: .center) {
                    if let image {
                        image
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    Text(title)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        }.background(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .fill(color)
        )
    }
}
