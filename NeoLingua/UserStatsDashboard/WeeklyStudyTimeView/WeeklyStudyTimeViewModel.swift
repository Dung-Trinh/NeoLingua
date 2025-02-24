import Foundation

protocol WeeklyStudyTimeViewModel {
    var dailyMinutes: [Int] { get }
    var averageStudyTime: Int { get }
    
    func dayAbbreviation(for index: Int) -> String
}

class WeeklyStudyTimeViewModelImpl: WeeklyStudyTimeViewModel {
    let dailyMinutes = [8, 9, 20, 14, 12, 30, 15]
    let averageStudyTime: Int = 15
    
    func dayAbbreviation(for index: Int) -> String {
        let days = ["Mo", "Di", "Mi", "Do", "Fr", "Sa","So"]
        return days[index]
    }
}
