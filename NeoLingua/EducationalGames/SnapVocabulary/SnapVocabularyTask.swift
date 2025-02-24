import Foundation

struct SnapVocabularyTask: Codable, Identifiable {
    let id: String
    let userId: String
    let coordinates: Location
    let imageUrl: String
    let vocabulary: [String]
}
