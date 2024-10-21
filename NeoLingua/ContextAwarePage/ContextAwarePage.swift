import SwiftUI
import _PhotosUI_SwiftUI

struct ContextAwarePage<ViewModel>: View where ViewModel: ContextAwarePageViewModel {
    @StateObject var viewModel: ViewModel    
    var body: some View {
        VStack {
            VStack {
                if let selectedImage = viewModel.selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                }
                PhotosPicker(
                    selection: $viewModel.selectedPhotos,
                    maxSelectionCount: 1,
                    selectionBehavior: .ordered,
                    matching: .images
                ) {
                    Label("Select a image", systemImage: "photo")
                }
            }
            .padding()
            .onChange(of: viewModel.selectedPhotos) { _, _ in
                viewModel.convertDataToImage()
            }
            Button("upload") {
                Task {
                    await viewModel.uploadImage()
                    
                }
            }
            Button("requestVisionAPI") {
                Task {
                    await viewModel.requestVisionAPI()
                }
            }
            
            Button("requestVisionAPI3") {
                Task {
                    try? await viewModel.requestVisionAPI3()
                }
            }
        }
    }
}
