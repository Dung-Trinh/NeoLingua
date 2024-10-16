import SwiftUI
import ActivityIndicatorView

struct ActivityIndicatorModifier: AnimatableModifier {
    var isLoading: Bool

    init(isLoading: Bool, color: Color = .primary, lineWidth: CGFloat = 3) {
        self.isLoading = isLoading
    }

    var animatableData: Bool {
        get { isLoading }
        set { isLoading = newValue }
    }

    func body(content: Content) -> some View {
        ZStack {
            if isLoading {
                GeometryReader { geometry in
                    ZStack(alignment: .center) {
                        content
                            .disabled(isLoading)
                            .blur(radius: isLoading ? 3 : 0)

                        VStack {
                            Text("Loading...")
                            ActivityIndicatorView(isVisible: .constant(true), type: .rotatingDots(count: 5))
                                .frame(width: 50.0, height: 50.0)
                                .foregroundColor(.red)
                        }
                        .frame(
                            width: geometry.size.width / 2,
                            height: geometry.size.height / 5
                        )
                        .background(Color.secondary.colorInvert())
                        .foregroundColor(Color.primary)
                        .cornerRadius(20)
                        .opacity(self.isLoading ? 1 : 0)
                        .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                    }
                }
            } else {
                content
            }
        }
    }
}
