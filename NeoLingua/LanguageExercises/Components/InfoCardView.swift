import SwiftUI

struct InfoCardView: View {
    enum InfomationType {
        case hint
        case info
    }
    
    private var title: String?
    private var message: String
    private var type: InfomationType
    
    private var foregroundColor: Color {
        switch type {
            case .info: Color.blue
            case .hint: Color.orange
        }
    }
    
    private var backgroundColor: Color {
        switch type {
            case .info: foregroundColor.opacity(0.1)
            case .hint: foregroundColor.opacity(0.3)
        }
    }
    
    private var iconName: String {
        switch type {
            case .info: "info.circle"
            case .hint: "magnifyingglass.circle"
        }
    }
    
    init(
        title: String? = nil,
        message: String,
        type: InfomationType = .info
    ) {
        self.title = title
        self.message = message
        self.type = type
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: Styleguide.Margin.small) {
            ZStack {
                Circle()
                    .fill(foregroundColor)
                    .frame(width: 25, height: 25)
                
                Image(systemName: iconName)
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .bold))
            }
            
            VStack(alignment: .leading) {
                if let title = title {
                    Text(title)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                }
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
    }
}
