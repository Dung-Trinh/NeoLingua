enum VocabularyTaskType: String, Codable {
    case fillInTheBlanks = "FILL_IN_THE_BLANKS"
    case multipleChoice = "MULTIPLE_CHOICE"
    case sentenceAssembly = "SENTENCE_ASSEMBLY"
}

protocol VocabularyExercise: Codable {
    var id: String { get }
    var type: VocabularyTaskType { get }
    var question: String { get }
    var answer: String { get }
    var translation: String { get }
    
    func checkAnswer(_ userAnswer: String) -> Bool
}

protocol VocabularyTaskProtocol {
    var type: VocabularyTaskType { get }
    var question: String { get }
    var answer: String { get }
    var translation: String { get }
    var sentenceComponents: [String]? { get }
    var selectableWords: [String]? { get }
}

struct VocabularyTraining: Codable {
    let vocabularyTraining: [VocabularyTask]
}

class VocabularyTask: Codable, VocabularyTaskProtocol {
    var type: VocabularyTaskType
    
    let id: String
    let question: String
    let answer: String
    let translation: String
    var sentenceComponents: [String]?
    var selectableWords: [String]?
    
    init(
        id: String,
        type: VocabularyTaskType,
        question: String,
        answer: String,
        translation: String,
        sentenceComponents: [String]?,
        selectableWords: [String]?
    ) {
        self.id = id
        self.type = type
        self.question = question
        self.answer = answer
        self.translation = translation
        self.sentenceComponents = sentenceComponents
        self.selectableWords = selectableWords
    }
}

class WriteWordExercise: VocabularyExercise {
    var id: String
    var type: VocabularyTaskType
    var question: String
    var answer: String
    var translation: String

    init(
        id: String,
        type: VocabularyTaskType,
        question: String,
        answer: String,
        translation: String
    ) {
        self.id = id
        self.type = type
        self.question = question
        self.answer = answer
        self.translation = translation
    }
    
    func checkAnswer(_ userAnswer: String) -> Bool {
        return userAnswer.lowercased() == answer.lowercased()
    }
}

class SentenceBuildingExercise: VocabularyExercise {
    var id: String
    var type: VocabularyTaskType
    var question: String
    var answer: String
    var translation: String
    let sentenceComponents: [String]
    
    init(
        id: String,
        type: VocabularyTaskType,
        question: String,
        answer: String,
        translation: String,
        sentenceComponents: [String]
    ) {
        self.sentenceComponents = sentenceComponents
        self.id = id
        self.type = type
        self.question = question
        self.answer = answer
        self.translation = translation
    }
    
    func checkAnswer(_ userAnswer: String) -> Bool {
        return userAnswer.lowercased() == answer.lowercased()
    }
}

class ChooseWordExercise: VocabularyExercise {
    var id: String
    var type: VocabularyTaskType
    var question: String
    var answer: String
    var translation: String
    let selectableWords: [String]
    
    init(
        id: String,
        type: VocabularyTaskType,
        question: String,
        answer: String,
        translation: String,
        selectableWords: [String]
    ) {
        self.id = id
        self.type = type
        self.question = question
        self.answer = answer
        self.translation = translation
        self.selectableWords = selectableWords
    }
    
    func checkAnswer(_ userAnswer: String) -> Bool {
        return userAnswer.lowercased() == answer.lowercased()
    }
}
