import SwiftUI
import _PhotosUI_SwiftUI

struct ImageBasedLearningPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel = ImageBasedLearningPageViewModelImpl()
    
    var body: some View {
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
            
            Button("upload") {
                Task {
                    await viewModel.uploadImage()
                }
            }
            Button("requestVisionAPI3") {
                Task {
                    do {
                        await try viewModel.requestVisionAPI3()
                    } catch {
                        print("upload error: ", error.localizedDescription)
                    }
                    
                }
            }
        }
        .padding()
        .onChange(of: viewModel.selectedPhotos) { _, _ in
            viewModel.convertDataToImage()
        }
    }
}
