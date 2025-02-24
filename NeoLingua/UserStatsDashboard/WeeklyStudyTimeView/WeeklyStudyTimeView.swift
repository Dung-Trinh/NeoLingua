import SwiftUI

struct WeeklyStudyTimeView<ViewModel>: View where ViewModel: WeeklyStudyTimeViewModel {
    let viewModel: ViewModel
    
    var body: some View {
        VStack(spacing: Styleguide.Margin.small) {
            VStack(alignment: .leading, spacing: Styleguide.Margin.small) {
                HStack {
                    Image(systemName: "hourglass")
                    Text("Lernzeit dieser Woche")
                        .font(.system(size: 24))
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: Styleguide.Margin.extraSmall) {
                        Text("durchschnittlich")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        HStack(alignment: .firstTextBaseline, spacing: Styleguide.Margin.extraSmall) {
                            Text("~(\(viewModel.averageStudyTime)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.blue)
                            Text("min")
                                .font(.system(size: 16))
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            HStack(alignment: .bottom, spacing: Styleguide.Margin.small) {
                ForEach(0..<viewModel.dailyMinutes.count, id: \.self) { index in
                    VStack(alignment: .center) {
                        Text("\(viewModel.dailyMinutes[index])")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: 25, height: CGFloat(viewModel.dailyMinutes[index]) * 5)
                        
                        Text(viewModel.dayAbbreviation(for: index))
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
