import SwiftUI

struct EvaluatedQuestionView: View {
    let question: EvaluatedQuestion
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(question.question).font(.headline)
                Text(question.isAnswerRight ? "✅" : "❌")
                Text(question.hasWarnings ? "⚠️" : "")
                Spacer()
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                        
                }
            }.padding()
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Sample answer: \(question.sampleAnswer ?? "")")
                        .foregroundColor(question.isAnswerRight ? .green : .red)
                    
                    Text("Suggestions:")
                        .padding(.top, 5)
                    
                    ForEach(question.suggestions, id: \.self) { suggestion in
                        Text("• \(suggestion)").padding(.leading, 10)
                    }
                }
                .padding([.horizontal, .bottom])
                .cornerRadius(8)
            }
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ListeningTaskEvaluationView: View {
    let evaluation: ListeningTaskEvaluation
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("Solution").font(.title2).bold()
            ForEach(evaluation.evaluatedQuestions, id: \.id) { question in
                EvaluatedQuestionView(question: question)
                    .padding(.bottom, 5)
            }
        }
        .padding()
    }
}
