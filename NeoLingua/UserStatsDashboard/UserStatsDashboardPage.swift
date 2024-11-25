import SwiftUI
import ProgressIndicatorView
import SwiftUICharts

struct UserStatsDashboardPage: View {
    @StateObject var viewModel: UserStatsDashboardPageViewModellImpl
    @EnvironmentObject private var router: Router
    @State private var showProgressIndicator: Bool = true
    @State private var progress: CGFloat = 0.0
    
    var data: PieChartData = makeData()
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                Text("Wochenrücklick").font(.title).bold().multilineTextAlignment(.leading)
                VStack(alignment: .leading, spacing: Styleguide.Margin.medium) {
                    VStack {
                        Text("Deine Lernstatistiken").font(.title3)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Styleguide.Margin.medium) {
                                StatsTile(title: "Endeckte Vokabeln", number: "21", percentageChange: "↑ 10% besser als letzte Woche", percentageChangeTextColor: .green, iconName: "text.magnifyingglass")
                                StatsTile(title: "Hörgenauigkeit", number: "95%", percentageChange: "↑ 3% besser als letzte Woche", percentageChangeTextColor: .green, iconName: "ear.badge.waveform")
                                StatsTile(title: "gramm. Genauigkeit", number: "85%", percentageChange: "↓ 5% weniger als letzte Woche", percentageChangeTextColor: .red, iconName: "scope")
                            }
                        }
                    }
                    WeeklyMinutesView()
                    PieChart(chartData: data)
                        .touchOverlay(chartData: data)
                        .headerBox(chartData: data)
                        .legends(chartData: data, columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())])
                        .frame(minWidth: 150, maxWidth: .infinity, minHeight: 150, idealHeight: 300, maxHeight: 300, alignment: .center)
                        .id(data.id)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .frame(width: .infinity)
                    
                }
            }
        }.padding()
    }
    
    static func makeData() -> PieChartData {
        let data = PieDataSet(
            dataPoints: [
                PieChartDataPoint(value: 50, description: "Vokabeln",   colour: .blue  , label: .icon(systemName: "list.bullet.rectangle", colour: .white, size: 30)),
                PieChartDataPoint(value: 20, description: "Sprechen",   colour: .red   , label: .icon(systemName: "bubble.left.and.text.bubble.right", colour: .white, size: 30)),
                PieChartDataPoint(value: 30, description: "Hörverstehen", colour: .purple, label: .icon(systemName: "ear.badge.waveform", colour: .white, size: 30)),
            ],
            legendTitle: "Data")
        
        return PieChartData(
            dataSets: data,
            metadata: ChartMetadata(title: "Erledigte Aufgaben nach Kategorie in dieser Woche", subtitle: "in %"),
            chartStyle: PieChartStyle(infoBoxPlacement: .header)
        )
    }
}

struct WeeklyMinutesView: View {
    var dailyMinutes = [8, 9, 20, 14, 12, 30, 15]
    
    var body: some View {
        VStack(spacing: 6) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "hourglass")
                    Text("Lernzeit dieser Woche")
                        .font(.system(size: 24))
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("durchschnittlich")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("~15")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.blue)
                            Text("min")
                                .font(.system(size: 16))
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(0..<dailyMinutes.count, id: \.self) { index in
                    VStack(alignment: .center) {
                        Text("\(dailyMinutes[index])")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: 25, height: CGFloat(dailyMinutes[index]) * 5)
                        
                        Text(dayAbbreviation(for: index))
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
    
    func dayAbbreviation(for index: Int) -> String {
        let days = ["Mo", "Di", "Mi", "Do", "Fr", "Sa","So"]
        return days[index]
    }
}

struct StatsTile: View {
    var title: String = ""
    var number: String = ""
    var percentageChange: String = ""
    var percentageChangeTextColor: Color?
    var iconName: String = ""
    var iconColor: Color?
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 16))
            
            HStack(alignment: .center, spacing: 4) {
                Image(systemName: iconName)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(iconColor != nil ? iconColor : .orange)
                
                Text(number)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
            }
            
            Text(percentageChange)
                .font(.system(size: 12))
                .foregroundColor(percentageChangeTextColor != nil ? percentageChangeTextColor: .gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
