import SwiftUI

struct PageHeader: View {
    var title: String
    var subtitle: String
    var textAlignment: HorizontalAlignment = .leading
    
    var body: some View {
        HStack() {
            VStack(alignment: textAlignment) {
                Text(title)
                    .font(.title).bold()
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .if(textAlignment == .center, transform: { view in
                        view.frame(maxWidth: .infinity, alignment: .center)
                    })
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .if(textAlignment == .center, transform: { view in
                        view.frame(maxWidth: .infinity, alignment: .center)
                    })
            }
            Spacer()
        }
    }
}
