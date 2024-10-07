import SwiftUI

struct LearningOverviewPage<ViewModel>: View where ViewModel: LearningOverviewPageView {
    @StateObject var viewModel: ViewModel
    var body: some View {
        VStack {
           Text("Hallo")
            Button("getLocation von Google") {
                Task {
                    try await viewModel.fetchLocation()
                }
            }
            
            Button("structed data") {
                Task {
                    await viewModel.startChat()
                }
            }
            
            Button("start assistent") {
                Task {
                    await viewModel.startChatWithAssistant()
                }
            }

        }
 
    }
}


