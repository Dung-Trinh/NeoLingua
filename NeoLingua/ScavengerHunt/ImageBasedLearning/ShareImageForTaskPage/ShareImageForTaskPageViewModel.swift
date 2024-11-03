import SwiftUI

protocol ShareImageForTaskPageViewModel: ObservableObject {
    
}

class ShareImageForTaskPageViewModelImpl: ShareImageForTaskPageViewModel {
    let sharedContentForTask: SharedContentForTask
    
    init(sharedContentForTask: SharedContentForTask) {
        self.sharedContentForTask = sharedContentForTask
    }
}
