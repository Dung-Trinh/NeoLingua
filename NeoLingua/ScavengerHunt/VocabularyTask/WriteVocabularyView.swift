import SwiftUI

struct WriteVocabularyView: View {
    @Binding var userInputText: String
    var exercise: WriteWordExercise
    
    var body: some View {
        VStack(spacing: Styleguide.Margin.medium) {
            InfoCardView(message: "Fill in the blanks to complete the sentence.").padding(.bottom, Styleguide.Margin.small)
            Text(exercise.question)
            VStack {
                Text("Translation:")
                Text(exercise.translation)
            }
            TextField("your answer ...", text: $userInputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }.padding()
    }
}
