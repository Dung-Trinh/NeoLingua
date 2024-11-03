import SwiftUI

struct ShareImageForTaskPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: ShareImageForTaskPageViewModelImpl

    var body: some View {
        VStack {
            Image(uiImage: viewModel.sharedContentForTask.image)
                .resizable()
                .scaledToFit()
        }
    }
}
