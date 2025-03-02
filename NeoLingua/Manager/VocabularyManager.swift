import Foundation
import SwiftOpenAI

class VocabularyManager {
    let service = OpenAIServiceProvider.shared
    let openAiServiceHelper = OpenAIManager()
    let assistantID = ProdENV().VOCABULARY_ASSISTANT_ID
    var threadID = ""
    
    func getDetailedFeedback(userInput: String, taskId: String) async  throws -> String {
        let prompt = "explain in detail why this answer is wrong for the following task with the taskId: \(taskId). user input: \"\"\"\(userInput)\"\"\""
        try await openAiServiceHelper.sendUserMessageToThread(message: prompt, threadID: threadID)
        
        let jsonStringResponse = try await openAiServiceHelper.getJsonResponseAfterRun(
            assistantID: assistantID,
            threadID: threadID
        )
        
        print("jsonStringResponse")
        print(jsonStringResponse)
        
        if let jsonData = jsonStringResponse.data(using: .utf8) {
            let decodedData = try JSONDecoder().decode(DetailedFeedback.self, from: jsonData)
            return decodedData.explanation
        }
        throw "getDetailedFeedback error"
    }
    
    func fetchVocabularyTraining(prompt: String) async throws -> [VocabularyExercise] {
        if CommandLine.arguments.contains("--useMockData") {
            return TestData.vocabularyTasks
        }
        let languageLevel = UserDefaults().getLevelOfLanguage().rawValue
        let parameters = MessageParameter(
            role: .user,
            content: "\(prompt) adapt the tasks to language level \(languageLevel))"
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
                let sentenceTask = SentenceBuildingExercise(
                    id: task.id,
                    type: task.type,
                    question: task.question,
                    answer: task.answer,
                    translation: task.translation
                )
                exercises.append(sentenceTask)
                
                
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

struct DetailedFeedback: Decodable {
    let explanation: String
}
