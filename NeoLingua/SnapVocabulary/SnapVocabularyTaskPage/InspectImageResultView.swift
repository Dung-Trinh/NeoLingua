import SwiftUI

struct InspectImageResultView: View {
    let resultData: InspectImageForVocabularyResult
    let searchedVocabulary: [String]
    let lastUserInput: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Validation Result")
                .fontWeight(.bold)
                .padding(.bottom, 10)
                .multilineTextAlignment(.center)
            VStack(alignment: .leading){
                if resultData.foundSearchedVocabulary {
                    Text("You found one of the vocabulary: ")
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                    Text(searchedVocabulary.joined(separator: ","))
                        .font(.body)
                        .multilineTextAlignment(.leading)
                } else {
                    Text("⚠️ Unfortunately there is non of the searched vocabulary in the text")
                }
            }
            
            HStack {
                Text("Result:")
                    .font(.headline)
                Text(resultData.result.text)
                    .font(.body)
                    .foregroundColor(resultData.result.color)
            }
            
            if let correctedText = resultData.correctedText {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Your Input:")
                        .font(.headline)
                        .foregroundColor(.red)
                    Text(lastUserInput)
                        .font(.body)
                        .foregroundColor(.gray)
                    Text("Corrected Text:")
                        .font(.headline)
                        .foregroundColor(.green)
                    Text(.init(correctedText))
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .padding(.top, 10)
            }
        }
        .frame(width: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }
}

