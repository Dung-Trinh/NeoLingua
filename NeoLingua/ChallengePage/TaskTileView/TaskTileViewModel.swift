import Foundation

protocol TaskTileViewModel: Identifiable {
    var taskTitle: String { get }
    var iconName: String { get }
    var currentProgress: Int { get }
    var totalProgress: Int { get }
}

struct TaskTileViewModelImpl: TaskTileViewModel {
    var id: UUID = UUID()
    
    var taskTitle: String
    var iconName: String
    var currentProgress: Int
    var totalProgress: Int
}
