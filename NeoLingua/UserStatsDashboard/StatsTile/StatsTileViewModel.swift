import Foundation
import SwiftUI

protocol StatsTileViewModel: Identifiable {
    var title: String { get }
    var numericalValue: String { get }
    var percentageChange: String { get }
    var iconName: String { get }
    var percentageChangeTextColor: Color? { get }
    var iconColor: Color? { get }
}

class StatsTileViewModelImpl: StatsTileViewModel {
    var id: UUID = UUID()
    var title: String
    var numericalValue: String
    var percentageChange: String
    var iconName: String
    var percentageChangeTextColor: Color?
    var iconColor: Color?
    
    init(
        title: String,
        numericalValue: String,
        percentageChange: String,
        iconName: String,
        percentageChangeTextColor: Color? = nil,
        iconColor: Color? = nil
    ) {
        self.title = title
        self.numericalValue = numericalValue
        self.percentageChange = percentageChange
        self.iconName = iconName
        self.percentageChangeTextColor = percentageChangeTextColor
        self.iconColor = iconColor
    }
}
