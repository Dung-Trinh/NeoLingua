import SwiftUI

struct ExpandableTextView: View {
    @State var isExpanded: Bool = false
    @State var userText: String
    @State var correctedText: String
    @State var explanation: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Attention ⚠️").font(.headline)
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
                    Text("Your answer: \(userText)")
                        .foregroundColor(.red)
                    
                    Text("Corrected answer: \(correctedText)")
                        .foregroundColor(.green)
                    
                    Text("Explanation: \(explanation)")
                        .foregroundColor(.indigo)
                }
                .padding([.horizontal, .bottom])
                .cornerRadius(8)
            }
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
