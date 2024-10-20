import Foundation

struct WritingTask {
    let task: String
    let subtasks: [String]
    let conditions: Conditions
    
    struct Conditions {
        let minChars: Int
        let maxChars: Int
        let timeLimit: Int
        let formalTone: Bool
    }
    
    func allProperties() -> [(String, String)] {
        return [
            ("minChars", conditions.minChars.description),
            ("maxChars", conditions.maxChars.description),
            ("timeLimit", "\(conditions.timeLimit.description) Minuten"),
            ("formalTone", conditions.formalTone.description)
        ]
    }
}
protocol WritingTaskPageViewModel: ObservableObject {

}

class WritingTaskPageViewModelImpl: WritingTaskPageViewModel {
    let writingTask = WritingTask(
        task: "Write a text about the Kurpark in Wiesbaden.",
        subtasks: [
            "Describe the atmosphere of the park and what visitors can experience there.",
            "Mention at least one famous landmark or special spot in the park, such as the pond or a monument.",
            "Explain why the Kurpark is a popular place for both locals and tourists."
        ],
        conditions: WritingTask.Conditions(
            minChars: 250,
            maxChars: 500,
            timeLimit: 30,
            formalTone: true
        )
    )

}
