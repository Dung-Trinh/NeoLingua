import SwiftUI

struct ConversationEvaluationView: View {
    let evaluation: ConversationEvaluation
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Styleguide.Margin.medium) {
                Text("Evaluation")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, Styleguide.Margin.small)
                
                VStack(alignment: .leading, spacing: Styleguide.Margin.small) {
                    Text("Rating: \(String(format: "%.1f", evaluation.rating))/10")
                        .font(.title2)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: Styleguide.Margin.small) {
                    Text("Grammar: \(evaluation.grammar)")
                        .font(.body)
                    Text("Word Choice: \(evaluation.wordChoice)")
                        .font(.body)
                    Text("Structure: \(evaluation.structure)")
                        .font(.body)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: Styleguide.Margin.medium) {
                    Text("Tasks Completion")
                        .font(.headline)
                    
                    ForEach(evaluation.tasksCompletion) { taskCompletion in
                        HStack {
                            Image(systemName: taskCompletion.isCompleted ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(taskCompletion.isCompleted ? .green : .red)
                            VStack(alignment: .leading) {
                                Text(taskCompletion.task)
                                    .font(.body)
                                    .fontWeight(.medium)
                                if let suggestion = taskCompletion.suggestion {
                                    Text("Suggestion: \(suggestion)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                        }
                    }
                }
            }
            .cornerRadius(10)
            .padding()
            .background(RoundedRectangle(cornerRadius: 15).fill(Color(.systemGray6)))
        }
    }
}
