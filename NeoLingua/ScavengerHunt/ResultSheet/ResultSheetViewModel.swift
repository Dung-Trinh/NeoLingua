class ResultSheetViewModel {
    enum AnswerResult {
        case correct
        case incorrect
    }
    
    let result: AnswerResult
    let text: String
    let action: () -> Void

    init(
        result: AnswerResult,
        text: String,
        action: @escaping () -> Void
    ) {
        self.result = result
        self.text = text
        self.action = action
    }
}
