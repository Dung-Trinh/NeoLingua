import SwiftUI
import ProgressIndicatorView
import SwiftUICharts

struct UserStatsDashboardPage<ViewModel>: View where ViewModel: UserStatsDashboardPageViewModel {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                Text("Wochenrücklick").font(.title).bold().multilineTextAlignment(.leading)
                VStack(alignment: .leading, spacing: Styleguide.Margin.medium) {
                    VStack {
                        Text("Deine Lernstatistiken").font(.title3)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Styleguide.Margin.medium) {
                                ForEach(viewModel.statsTileVMs) { vm in
                                    StatsTile(viewModel: vm)
                                }
                            }
                        }
                    }
                    WeeklyStudyTimeView(viewModel: WeeklyStudyTimeViewModelImpl())
                    PieChart(chartData: viewModel.chartData)
                        .touchOverlay(chartData: viewModel.chartData)
                        .headerBox(chartData: viewModel.chartData)
                        .legends(chartData: viewModel.chartData, columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())])
                        .frame(
                            minWidth: 150,
                            maxWidth: .infinity,
                            minHeight: 150,
                            idealHeight: 300,
                            maxHeight: 300,
                            alignment: .center
                        )
                        .id(viewModel.chartData.id)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .frame(width: .infinity)
                }
            }
        }.padding()
    }
}
