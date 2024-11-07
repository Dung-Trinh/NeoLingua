import SwiftUI

struct SentenceBuildingView: View {
    @Binding var userAnswer: String
    @State var exercise: SentenceBuildingExercise
    @State private var selectedWords: [String] = []
    @State private var usedIndices: Set<Int> = []
    let columns = [
            GridItem(.adaptive(minimum: 80))
        ]
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                VStack {
                    Text("Combine the sentence components to form this sentence:").bold()
                    Text("Translation: " + exercise.translation).padding()
                }
                Text("ⓘ Tap the words in the correct order:").font(.headline)
                VStack {
                    LazyVGrid(columns: columns, spacing: 10) {
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
                                        .padding(3)
                                        .frame(minWidth: 80)
                                        .background(usedIndices.contains(index) ? Color.gray.opacity(0.5) : Color.blue.opacity(0.2))
                                        .foregroundColor(.black)
                                        .cornerRadius(8)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                }
                            )
                        }
                    }
                }
            }
            
            VStack {
                Text("Your Selection:").font(.subheadline)
                HStack {
                    Text(selectedWords.joined(separator: " "))
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
