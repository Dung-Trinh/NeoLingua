import Foundation


struct ConversationResponse: Codable {
    let endOfConversation: Bool?
    let answer: String
}

struct IntroResponse: Codable {
    let introText: String
}

struct TaskCompletion: Codable, Identifiable {
    let id: UUID
    let task: String
    let isCompleted: Bool
    let suggestion: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.task = try container.decode(String.self, forKey: .task)
        self.isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        self.suggestion = try container.decodeIfPresent(String.self, forKey: .suggestion)
        id = UUID()
    }
    
    init(
        task: String,
        isCompleted: Bool,
        suggestion: String?
    ) {
        self.task = task
        self.isCompleted = isCompleted
        self.suggestion = suggestion
        id = UUID()
    }
}

struct ConversationEvaluation: Codable {
    let id: UUID
    let grammar: String
    let wordChoice: String
    let structure: String
    let tasksCompletion: [TaskCompletion]
    let rating: Double
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.grammar = try container.decode(String.self, forKey: .grammar)
        self.wordChoice = try container.decode(String.self, forKey: .wordChoice)
        self.structure = try container.decode(String.self, forKey: .structure)
        self.tasksCompletion = try container.decode([TaskCompletion].self, forKey: .tasksCompletion)
        self.rating = try container.decode(Double.self, forKey: .rating)
        id = UUID()
    }
    
    init(
        grammar: String,
        wordChoice: String,
        structure: String,
        tasksCompletion: [TaskCompletion],
        rating: Double
    ) {
        id = UUID()
        self.grammar = grammar
        self.wordChoice = wordChoice
        self.structure = structure
        self.tasksCompletion = tasksCompletion
        self.rating = rating
    }
}
