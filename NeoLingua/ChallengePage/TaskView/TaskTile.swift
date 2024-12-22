import SwiftUI

struct TaskTileViewModel {
    var taskTitle: String
    var iconName: String
    var currentProgress: Int
    var totalProgress: Int
}

struct TaskTile: View {
    let viewModel: TaskTileViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: viewModel.iconName)
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.blue)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.taskTitle)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                ProgressView(value: Double(viewModel.currentProgress) / Double(viewModel.totalProgress))
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .frame(height: 6)
                
                Text("\(viewModel.currentProgress)/\(viewModel.totalProgress)")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(12)
    }
}
