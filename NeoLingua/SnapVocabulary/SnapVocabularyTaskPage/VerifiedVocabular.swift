import Foundation

struct VerifiedVocabular: Codable, Identifiable {
    var id: String
    let name: String
    let isInImage: Bool
    let improvement: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.isInImage = try container.decode(Bool.self, forKey: .isInImage)
        self.improvement = try container.decodeIfPresent(String.self, forKey: .improvement)
        self.id = UUID().uuidString
    }
    
    init(name: String, isInImage: Bool, improvement: String?) {
        self.name = name
        self.isInImage = isInImage
        self.improvement = improvement
        self.id = UUID().uuidString
    }
}
