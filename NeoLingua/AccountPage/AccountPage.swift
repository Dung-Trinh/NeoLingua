import SwiftUI

struct AccountPage<ViewModel>: View where ViewModel: AccountPageViewModel {
    @StateObject var viewModel: ViewModel
    @EnvironmentObject private var router: Router
    let estimationOfDailyUseTime: [Int] = [5,10,15,30,60]
    @State var firstAppear: Bool = false
    
    var body: some View {
        VStack {
            Text("Profile").font(.title).bold()
            if let profileData = viewModel.profileData {
                VStack {
                    Image(systemName:"person.crop.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    
                    Text(profileData.username).font(.title2).bold().foregroundColor(.blue)
                    LevelView()
                }
            }
            
            Form {
                Section {
                    Picker("Sprachniveau", selection: $viewModel.selectedLevel) {
                        ForEach(LevelOfLanguage.allCases) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    
                    Picker("Tägliches Nutzungsziel (in Minuten):", selection: $viewModel.selectedDailyUseTime) {
                        ForEach(estimationOfDailyUseTime, id: \.self) { level in
                            Text("\(level)").tag(level)
                        }
                    }
                    
                    if let profileData = viewModel.profileData {
                        VStack(alignment: .leading) {
                            Text("Lernziele:")
                            VStack(alignment: .leading) {
                                ForEach(profileData.learningGoals, id: \.self) { item in
                                    HStack(alignment: .top) {
                                        Text("•")
                                        Text(item)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }.padding(.leading, Styleguide.Margin.medium)
                        }
                    }
                } header: {
                    Text("Personalisierte Lerneinstellunge")
                }
            }
            Spacer()
            Button("Logout") {
                viewModel.didTappedLogout()
            }
            .buttonStyle(.bordered)
            .foregroundColor(.red)
        }
        .padding()
        .onAppear {
            if firstAppear == false {
                Task {
                    await viewModel.fetchProfileData()
                    firstAppear = true
                }
            }
        }
        .background(Color(.systemGray6))
        .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
        .navigationDestination(for: Route.self) { route in
            router.destination(for: route)
        }
    }
}

struct LevelView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Image(systemName: "bolt.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.blue)
                
                Text("3179 XP Punkte")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.blue)
            }
            
            ProgressView(value: 0.75)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(height: 16)
                .padding(.vertical, 4)
            
            HStack {
                Text("LEVEL 5")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text("165 XP to")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                Text("LEVEL 6")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
