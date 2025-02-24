import Foundation

protocol ChallengePageViewModel: ObservableObject {
    var weeklyChallenge: [TaskTileViewModelImpl] { get }
    var todaysChallenge: [TaskTileViewModelImpl] { get }
    var recommendationsForLearningGoal: [TaskTileViewModelImpl] { get }
}

class ChallengePageViewModellImpl: ChallengePageViewModel {
    let weeklyChallenge: [TaskTileViewModelImpl] = [
        TaskTileViewModelImpl(
            taskTitle: "Complete 3 scavenger hunts",
            iconName: "map.fill",
            currentProgress: 1, totalProgress: 3
        )
    ]
    
    let todaysChallenge: [TaskTileViewModelImpl] = [
        TaskTileViewModelImpl(
            taskTitle: "Complete 3 listening comprehension exercises",
            iconName: "ear.badge.waveform",
            currentProgress: 1,
            totalProgress: 2
        ),
        TaskTileViewModelImpl(
            taskTitle: "Find 5 vocabulary in SnapVocabulary",
            iconName: "list.bullet.rectangle",
            currentProgress: 4,
            totalProgress: 6
        )
    ]
    
    let recommendationsForLearningGoal: [TaskTileViewModelImpl] = [
        TaskTileViewModelImpl(
            taskTitle: "Practice a conversation in the hotel.",
            iconName: "bubble.left.and.text.bubble.right",
            currentProgress: 0,
            totalProgress: 1
        )
    ]
}
