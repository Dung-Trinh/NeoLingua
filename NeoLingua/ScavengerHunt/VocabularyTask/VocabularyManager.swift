import Foundation
import SwiftOpenAI

class VocabularyManager {
    let service = OpenAIServiceProvider.shared
    let openAiServiceHelper = OpenAIServiceHelper()
    let assistantID = ProdENV().VOCABULARY_ASSISTANT_ID
    var threadID = ""
    
    func fetchVocabularyTraining() async throws -> [VocabularyExercise] {
        let prompt = "create vocabulary task with the topic 'warmer damm' in Wiesbaden"
        let parameters = MessageParameter(
            role: .user,
            content: prompt
        )
        
        let thread = try await service.createThread(parameters: CreateThreadParameters())
        threadID = thread.id
        let _ = try await service.createMessage(
            threadID: threadID,
            parameters: parameters
        )
        
        let jsonStringResponse = try await openAiServiceHelper.getJsonResponseAfterRun(
            assistantID: assistantID,
            threadID: threadID
        )
        print("createConversationResponse Text:")
        print(jsonStringResponse)
        
        if let jsonData = jsonStringResponse.data(using: .utf8) {
            let decodedData = try decodeTasks(from: jsonData)
            return decodedData
        }
        
        return []
    }
    
    private func decodeTasks(from jsonData: Data) throws -> [VocabularyExercise] {
        let decoder = JSONDecoder()
        var exercises: [VocabularyExercise] = []
        let taskData = try decoder.decode(VocabularyTraining.self, from: jsonData)
        for task in taskData.vocabularyTraining {
            switch task.type {
            case .fillInTheBlanks:
                let fillInTheBlanksTask = WriteWordExercise(
                    id: task.id,
                    type: task.type,
                    question: task.question,
                    answer: task.answer,
                    translation: task.translation
                )
                exercises.append(fillInTheBlanksTask)
                
            case .sentenceAssembly:
                if let components = task.sentenceComponents {
                    let sentenceTask = SentenceBuildingExercise(
                        id: task.id,
                        type: task.type,
                        question: task.question,
                        answer: task.answer,
                        translation: task.translation,
                        sentenceComponents: task.sentenceComponents ?? []
                    )
                    exercises.append(sentenceTask)
                }
                
            case .multipleChoice:
                if let words = task.selectableWords {
                    let multipleChoiceTask = ChooseWordExercise(
                        id: task.id,
                        type: task.type,
                        question: task.question,
                        answer: task.answer,
                        translation: task.translation,
                        selectableWords: words
                    )
                    exercises.append(multipleChoiceTask)
                }
            }
        }
        return exercises
    }
}
