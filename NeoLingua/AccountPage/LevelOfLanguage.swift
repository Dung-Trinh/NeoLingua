import Foundation

enum LevelOfLanguage: String, Codable, CaseIterable, Identifiable {
    var id: LevelOfLanguage { self }
    
    case A1
    case A2
    case B1
    case B2
    case C1
    case C2
}
