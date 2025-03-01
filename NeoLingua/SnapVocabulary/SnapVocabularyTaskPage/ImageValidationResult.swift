import Foundation
import SwiftUI

struct ImageValidationResult: Codable {
    let isMatching: Bool
    let reason: String
    let confidenceScore: Double
}

struct InspectImageForVocabularyResult: Codable {
    let foundSearchedVocabulary: Bool
    let result: EvaluationStatus
    let correctedText: String?
    let points: Double?
}

enum EvaluationStatus: String, Codable {
    case correct
    case wrong
    case almostCorrect
    
    var color: Color {
        switch self {
            case.correct: .green
            case .wrong: .red
            case .almostCorrect: .orange
        }
    }
    
    var text: String {
        switch self {
            case.correct: "correct ✅"
            case .wrong: "wrong ❌"
            case .almostCorrect: "almost correct ⚠️"
        }
    }
}

struct InspectImageForVocabularyHint: Codable {
    let hint: String
}

struct ValidateVocabularyInImageResult: Codable {
    let vocabulary: [VerifiedVocabular]
}
