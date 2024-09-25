import SwiftUI

struct BasicInputField: View {
    @Binding var input: String
    @State var isPasswordTextVisible = false

    let title: String
    let placeholderText: String
    let iconName: String
    var isSecurityField = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Styleguide.Margin.medium) {
            Text(title)
            HStack {
                Image(systemName: iconName)
                if isSecurityField {
                    if isPasswordTextVisible {
                        TextField(placeholderText, text: $input)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                    } else {
                        SecureField("Passwoord", text: $input)
                    }
                    Spacer()
                    Button {
                        self.isPasswordTextVisible.toggle()
                    } label: {
                        Image(systemName: isPasswordTextVisible ? "eye.slash" : "eye" ).foregroundColor(.black)
                    }.contentTransition(.symbolEffect(.replace))
                } else {
                    TextField(placeholderText, text: $input)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                }
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 2)
                    .foregroundColor(.black)
            )
        }
    }
}
