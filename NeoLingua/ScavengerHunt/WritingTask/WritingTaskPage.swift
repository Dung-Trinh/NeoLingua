import SwiftUI

struct WritingTaskPage: View {
    @EnvironmentObject private var router: Router
    @StateObject private var viewModel = WritingTaskPageViewModelImpl()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Task:")
                Text(viewModel.writingTask.task)
                Text("Subtask:")
                ForEach(viewModel.writingTask.subtasks, id: \.self) { subtask in
                    Text("• \(subtask)")
                }
                Text("Conditions:")
                ForEach(viewModel.writingTask.allProperties(), id: \.0) { (key, value) in
                    HStack {
                        Text("\(key): ")
                        Text(value)
                    }
                }
            }.padding()
        }
    }
}
