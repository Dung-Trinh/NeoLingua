enum VocabularyTrainingType: String, Codable {
    case writeVocabulary = "WriteVocabulary"
    case chooseVocabulary = "ChooseVocabulary"
    case sentenceBuilding = "SentenceBuilding"
}

protocol VocabularyTrainingProtocol {
    var type: VocabularyTrainingType { get }
    var question: String { get }
    var answer: String { get }
    var translation: String { get }
    
    func checkAnswer(_ userAnswer: String) -> Bool
}

class VocabularyTraining: Codable, VocabularyTrainingProtocol {
    let type: VocabularyTrainingType
    let question: String
    let answer: String
    let translation: String

    init(
        type: VocabularyTrainingType,
        question: String,
        answer: String,
        translation: String
    ) {
        self.type = type
        self.question = question
        self.answer = answer
        self.translation = translation
    }
    
    func checkAnswer(_ userAnswer: String) -> Bool {
        userAnswer.lowercased() == answer.lowercased()
    }
}

class WriteWordExercise: VocabularyTraining {
    init(
        question: String,
        answer: String,
        translation: String
    ) {
        super.init(
            type: .writeVocabulary,
            question: question,
            answer: answer,
            translation: translation
        )
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

class SentenceBuildingExercise: VocabularyTraining {
    let sentenceComponents: [String]
    
    init(
        question: String,
        sentenceComponents: [String],
        answer: String,
        translation: String
    ) {
        self.sentenceComponents = sentenceComponents
        super.init(
            type: .sentenceBuilding,
            question: question,
            answer: answer,
            translation: translation
        )
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

class ChooseWordExercise: VocabularyTraining {
    let words: [String]
    
    init(
        question: String,
        words: [String],
        answer: String,
        translation: String
    ) {
        self.words = words
        super.init(
            type: .chooseVocabulary,
            question: question,
            answer: answer,
            translation: translation
        )
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
