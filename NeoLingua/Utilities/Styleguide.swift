import Foundation
import SwiftUI

struct Styleguide {
    struct Margin {
        static let extraSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
    }
    
    struct PrimaryColor {
        static let darkBlue: Color = Color(red: 0.02, green: 0, blue: 0.63)
        static let purple: Color = Color(red: 0.99, green: 0, blue: 0.98)
    }

    struct ColorGradient {
        static let pastelGradient: LinearGradient = LinearGradient(
            gradient: Gradient(colors: [Color(#colorLiteral(red: 0.8196078538894653, green: 0.41960784792900085, blue: 0.6470588445663452, alpha: 1)), Color(#colorLiteral(red: 0.5254902243614197, green: 0.658823549747467, blue: 0.9058823585510254, alpha: 1)), Color(#colorLiteral(red: 0.37254902720451355, green: 0.9843137264251709, blue: 0.9450980424880981, alpha: 1))]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
