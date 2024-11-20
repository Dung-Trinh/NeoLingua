import SwiftUI

struct MultipleChoiceView: View {
    @Binding var userInputText: String
    @State private var showCorrectAnswer = false
    @State private var selectedAnswerIndex: Int? = nil
    var exercise: ChooseWordExercise
    let action: () -> Void

    var body: some View {
        VStack {
            InfoCardView(message: "Select the correct word to complete the sentence!").padding(.bottom, Styleguide.Margin.large)
            Text(exercise.question)
            VStack(spacing: Styleguide.Margin.extraLarge){
                ForEach(0..<exercise.selectableWords.count, id: \.self) { index in
                    Button(action: {
                        selectedAnswerIndex = index
                        showCorrectAnswer = true
                        userInputText = exercise.selectableWords[index]
                        action()
                    }) {
                        Text(exercise.selectableWords[index])
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(buttonColor(for: index))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                    }
                    .disabled(showCorrectAnswer)
                }
            }.padding()
        }
    }
    private func buttonColor(for index: Int) -> Color {
        if showCorrectAnswer {
            if exercise.selectableWords[index] == exercise.answer {
                return .green
            } else if index == selectedAnswerIndex {
                return .red
            }
        }
        return .clear
    }
}
