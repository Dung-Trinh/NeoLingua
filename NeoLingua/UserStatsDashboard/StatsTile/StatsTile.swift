import SwiftUI

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
