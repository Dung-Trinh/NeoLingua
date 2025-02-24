import SwiftUI

struct StatsTile<ViewModel>: View where ViewModel: StatsTileViewModel {
    var viewModel: ViewModel
    private var iconNameColor: Color? {
        viewModel.iconColor != nil ? viewModel.iconColor : .orange
    }
    private var percentageChangeColor: Color? {
        viewModel.percentageChangeTextColor != nil ? viewModel.percentageChangeTextColor: .gray
    }
    
    var body: some View {
        VStack(spacing: Styleguide.Margin.extraSmall) {
            Text(viewModel.title)
                .font(.system(size: 16))
            
            HStack(alignment: .center, spacing: Styleguide.Margin.extraSmall) {
                Image(systemName: viewModel.iconName)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(iconNameColor)
                
                Text(viewModel.numericalValue)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
            }
            
            Text(viewModel.percentageChange)
                .font(.system(size: 12))
                .foregroundColor(percentageChangeColor)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
