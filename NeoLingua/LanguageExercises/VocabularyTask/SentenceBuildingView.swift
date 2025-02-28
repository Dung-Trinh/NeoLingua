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
        VStack(spacing: Styleguide.Margin.large) {
            VStack {
                InfoCardView(message: "Verbinden Sie die Satzteile zu einem Satz!").padding(.bottom, Styleguide.Margin.large)
                VStack(alignment: .leading) {
                    Text("Translation:").bold()
                    Text(exercise.translation)
                }.padding(.bottom, Styleguide.Margin.large)
                Text("ⓘ Tap the words in the correct order").font(.headline)
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
                }.padding(.bottom, Styleguide.Margin.large)
                
            }
            
            VStack {
                Text("Your Selection:").font(.headline)
                HStack {
                    Text(selectedWords.joined(separator: " "))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(
                        cornerRadius: 10,
                        style: .continuous
                    )
                    .stroke(.blue, lineWidth: 2)
                )
            }
            Button("Reset selection") {
                resetSelection()
            }
            .buttonStyle(.bordered)
            .tint(.pink)
            
        }.padding()
    }
    
    private func resetSelection() {
        selectedWords = []
        usedIndices = []
        userAnswer = ""
    }
}
