import Foundation
import SwiftUICharts

protocol UserStatsDashboardPageViewModel: ObservableObject {
    var statsTileVMs: [StatsTileViewModelImpl] { get }
    var chartData: PieChartData { get }
}

class UserStatsDashboardPageViewModellImpl: UserStatsDashboardPageViewModel {
    var statsTileVMs: [StatsTileViewModelImpl] = [
        .init(
            title: "Endeckte Vokabeln",
            numericalValue: "21",
            percentageChange: "↑ 10% besser als letzte Woche",
            iconName: "text.magnifyingglass",
            percentageChangeTextColor: .green
        ),
        .init(
            title: "Hörgenauigkeit",
            numericalValue: "95%",
            percentageChange: "↑ 3% besser als letzte Woche",
            iconName: "ear.badge.waveform",
            percentageChangeTextColor: .green
        ),
        .init(
            title: "gramm. Genauigkeit",
            numericalValue: "85%",
            percentageChange: "↓ 5% weniger als letzte Woche",
            iconName: "scope",
            percentageChangeTextColor: .red
        ),
    ]
    let chartData: PieChartData
    
    private var dataSet: PieDataSet = PieDataSet(
        dataPoints: [
            PieChartDataPoint(
                value: 50,
                description: "Vokabeln",
                colour: .blue,
                label: .icon(systemName: "list.bullet.rectangle", colour: .white, size: 30)
            ),
            PieChartDataPoint(
                value: 20,
                description: "Sprechen",
                colour: .red,
                label: .icon(systemName: "bubble.left.and.text.bubble.right", colour: .white, size: 30)
            ),
            PieChartDataPoint(
                value: 30,
                description: "Hörverstehen",
                colour: .purple, label: .icon(systemName: "ear.badge.waveform", colour: .white, size: 30)
            )
        ],
        legendTitle: "Data"
    )
    
    init() {
        chartData = PieChartData(
            dataSets: dataSet,
            metadata: ChartMetadata(
                title: "Erledigte Aufgaben nach Kategorie in dieser Woche",
                subtitle: "in %"
            ),
            chartStyle: PieChartStyle(infoBoxPlacement: .header)
        )
    }
}
