import Foundation

protocol TaskLocationPageViewModel: ObservableObject {

}

class TaskLocationPageViewModelImpl: TaskLocationPageViewModel {
    @Published var taskLocation: TaskLocation

    init(taskLocation: TaskLocation) {
        
        self.taskLocation = taskLocation
    }
}
