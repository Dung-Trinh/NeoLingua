import Foundation
import SwiftUI

struct OnboardingOnboardingContentResponse: Codable {
    let content: [OnboardingContent]
}

struct OnboardingContent: Identifiable, Codable {
    let id: Int
    let title: String
    let subtitle: String
    let imageUrl: String?
}
