import Foundation

struct ListeningQuestion: Codable {
    let id: String
    let question: String
}

struct ListeningExercise: Codable {
    let textForSpeech: String
    let listeningQuestions: [ListeningQuestion]
}

struct EvaluatedQuestion: Codable {
    let id: String
    let question: String
    let isAnswerRight: Bool
    let rightAnswer: String?
    let suggestions: [String]
}

struct ListeningTaskEvaluation: Codable {
    let evaluatedQuestions: [EvaluatedQuestion]
}
