import SwiftUI

struct WriteVocabularyView: View {
    @Binding var userInputText: String
    var exercise: WriteWordExercise
    
    var body: some View {
        VStack(spacing: Styleguide.Margin.medium) {
            InfoCardView(message: "Füllen Sie die Lücken aus, um den Satz zu vervollständigen.").padding(.bottom, Styleguide.Margin.small)
            Text(exercise.question)
            VStack {
                Text("Translation:").bold()
                Text(exercise.translation)
            }
            TextField("your answer ...", text: $userInputText)
                .autocorrectionDisabled()
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }.padding()
    }
}
