import SwiftUI

struct AccountPage<ViewModel>: View where ViewModel: AccountPageViewModel {
    @StateObject var viewModel: ViewModel
    @EnvironmentObject private var router: Router
    @State private var firstAppear: Bool = false
    
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
                        ForEach(viewModel.estimationOfDailyUseTime, id: \.self) { level in
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
