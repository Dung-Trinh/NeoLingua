import SwiftUI

struct ChipView: View {
    @StateObject var viewModel: ChipViewModel
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: Styleguide.Margin.small) {
            Text(viewModel.text)
                .font(.system(size: 12))
                .fontWeight(.bold)
                .foregroundColor(getForegroundColor())
                .padding(Styleguide.Margin.extraSmall)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(getBackgroundColor()).opacity(0.5)
                ).onTapGesture {
                    action()
                }
        }
    }
    
    func getBackgroundColor() -> Color {
        return viewModel.isSelected ? .green : .gray.opacity(0.8)
    }
    
    func getForegroundColor() -> Color {
        return viewModel.isSelected ? .white : .black
    }
}

class ChipViewModel: Identifiable, ObservableObject {
    let id: String = UUID().uuidString
    var text: String
    @Published var isSelected: Bool = false
    
    init(text: String) {
        self.text = text
    }
}
