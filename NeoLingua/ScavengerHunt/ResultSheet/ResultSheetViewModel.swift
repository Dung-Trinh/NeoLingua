enum AnswerResult {
    case correct
    case incorrect
}

protocol ResultSheetViewModel {
    var result: AnswerResult { get }
    var text: String { get }
    var showDetailedFeedbackButton: Bool { get }
    var action: () -> Void { get }
    var getDetailedFeedback: () -> Void? { get }
    
}

class ResultSheetViewModelImpl: ResultSheetViewModel {
    let result: AnswerResult
    let text: String
    let action: () -> Void
    let getDetailedFeedback: () -> Void?
    let showDetailedFeedbackButton: Bool

    init(
        result: AnswerResult,
        text: String,
        action: @escaping () -> Void,
        getDetailedFeedback: @escaping () -> Void?,
        showDetailedFeedbackButton: Bool = false
    ) {
        self.result = result
        self.text = text
        self.action = action
        self.getDetailedFeedback = getDetailedFeedback
        self.showDetailedFeedbackButton = showDetailedFeedbackButton
    }
}
