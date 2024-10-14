import SwiftUI

struct WriteVocabularyView: View {
    @Binding var userInputText: String
    var exercise: WriteWordExercise
    
    var body: some View {
        VStack {
            Text(exercise.question)
            TextField("Deine Antwort", text: $userInputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }.padding()
    }
}
