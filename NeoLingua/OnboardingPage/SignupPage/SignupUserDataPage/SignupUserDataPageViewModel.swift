import Foundation

protocol SignupUserDataPageViewModel: ObservableObject {
    var name: String { get set }
    var goalsInpiutField: String { get set }
    var estimationOfDailyUse: Int { get set }
    var learningGoals: [String] { get }

    func saveUserData() async
}

class SignupUserDataPageViewModelImpl: SignupUserDataPageViewModel {
    @Published var name: String = ""
    @Published var goalsInpiutField: String = ""
    @Published var learningGoals: [String] = []
    @Published var estimationOfDailyUse: Int = 0

    private let userDataManager = UserDataManagerImpl()

    func saveUserData() async {
        let data = ProfileData(
            name: "Gusto",
            learningGoals: ["sprechen", "schreiben"],
            estimationOfDailyUse: 8
        )
        
        do {
            try await userDataManager.saveUserData(userData: data)
        } catch let err {
            print("saveUserData ", err.localizedDescription)
        }
    }
}
