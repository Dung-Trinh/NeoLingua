import Foundation

protocol SignupUserDataPageViewModel: ObservableObject {
    var username: String { get set }
    var interestsInputText: String { get set }
    var estimationOfDailyUse: Int { get set }
    var estimationOfDailyUseTime: [Int] { get }
    var vms: [ChipViewModel] { get }
    var complexSkills: [ChipViewModel] { get }
    var isLoading: Bool { get }
    
    func saveUserData() async
    func didTapChipView(_ tappedChipVM: ChipViewModel)
}

class SignupUserDataPageViewModelImpl: SignupUserDataPageViewModel {
    @Published var username: String = ""
    @Published var interestsInputText: String = ""
    @Published var learningGoals: [String] = []
    @Published var estimationOfDailyUse: Int = 15
    @Published var router: Router
    @Published var vms: [ChipViewModel] = [
        ChipViewModel(text: "Schreiben"),
        ChipViewModel(text: "Lesen"),
        ChipViewModel(text: "Sprechen"),
        ChipViewModel(text: "Hören")
    ]
    @Published var complexSkills: [ChipViewModel] = [
        ChipViewModel(text: "Wortschatz "),
        ChipViewModel(text: "Aussprache"),
        ChipViewModel(text: "Grammatik"),
        ChipViewModel(text: "Gesprächsführung")
    ]
    @Published var estimationOfDailyUseTime: [Int] = [5,15,30,60]
    @Published var isLoading = false

    private let userDataManager = UserDataManagerImpl()
    
    init(router: Router) {
        self.router = router
    }
    
    func didTapChipView(_ tappedChipVM: ChipViewModel) {
        tappedChipVM.isSelected.toggle()
    }
    
    func saveUserData() async {
        isLoading = true
        defer { isLoading = false }
        
        var learningGoals = [String]()
        for vm in vms {
            if vm.isSelected {
                learningGoals.append(vm.text)
            }
        }
        
        for vm in complexSkills {
            if vm.isSelected {
                learningGoals.append(vm.text)
            }
        }
        
        let interestsWithoutSpaces = interestsInputText.replacingOccurrences(of: " ", with: "")
        let interestsArray = interestsWithoutSpaces.components(separatedBy: ",")

        print(username)
        print(learningGoals.description)
        print(interestsArray)
        print(estimationOfDailyUse)

        let data = ProfileData(
            username: username,
            learningGoals: learningGoals,
            interests: interestsArray,
            estimationOfDailyUse: estimationOfDailyUse
        )
        
        do {
            try await userDataManager.saveUserData(userData: data)
            router.push(.loginSignup(.successfullyRegistered))
        } catch let err {
            print("saveUserData ", err.localizedDescription)
        }
    }
}
