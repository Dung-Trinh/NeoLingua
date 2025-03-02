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
    let hasWarnings: Bool
    let sampleAnswer: String
    let suggestions: [String]
}

struct ListeningTaskEvaluation: Codable {
    let evaluatedQuestions: [EvaluatedQuestion]
    
    func countCorrectAnswers() -> Int {
        return evaluatedQuestions.filter { $0.isAnswerRight }.count
    }
    
    func getScorePercentage() -> Double {
        let correctAnswers = Double(countCorrectAnswers())
        let questionAmount = Double(evaluatedQuestions.count)
        print(correctAnswers, questionAmount)
        return correctAnswers/questionAmount
    }
}
