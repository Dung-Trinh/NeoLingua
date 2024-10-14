import SwiftUI

struct SentenceBuildingView: View {
    @Binding var userAnswer: String
    @State var exercise: SentenceBuildingExercise
    @State private var selectedWords: [String] = []
    @State private var usedIndices: Set<Int> = []
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                Text("Tap the words in the correct order:").font(.headline)
                HStack {
                    ForEach(exercise.sentenceComponents.indices, id: \.self) { index in
                        let word = exercise.sentenceComponents[index]
                        Button(
                            action: {
                                if !usedIndices.contains(index) {
                                    selectedWords.append(word)
                                    usedIndices.insert(index)
                                    userAnswer = selectedWords.joined(separator: " ")
                                }
                            },
                            label: {
                                Text(word)
                                    .padding()
                                    .background(usedIndices.contains(index) ? Color.gray.opacity(0.5) : Color.blue.opacity(0.2))
                                    .foregroundColor(.black)
                                    .cornerRadius(8)
                            }
                        )
                    }
                }
            }
            
            VStack {
                Text("Your Selection:").font(.subheadline)
                HStack {
                    ForEach(selectedWords, id: \.self) { word in
                        Text(word)
                            .padding()
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            }
            Button(
                action: {
                    resetSelection()
                },
                label: {
                    Text("Reset selection")
                        .font(.headline)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                })
        }.padding()
    }
    
    private func resetSelection() {
        selectedWords = []
        usedIndices = []
        userAnswer = ""
    }
}
