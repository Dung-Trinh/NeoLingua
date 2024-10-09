import Foundation

protocol SignupUserDataPageViewModel: ObservableObject {
    var name: String { get set }
    var interestsInputText: String { get set }
    var estimationOfDailyUse: Int { get set }
    var estimationOfDailyUseTime: [Int] { get }
    var vms: [ChipViewModel] { get }
    var complexSkills: [ChipViewModel] { get }

    func saveUserData() async
    func didTapChipView(_ tappedChipVM: ChipViewModel)
}

class SignupUserDataPageViewModelImpl: SignupUserDataPageViewModel {
    @Published var name: String = "Dee"
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
        ChipViewModel(text: "Wortschatz erweitern"),
        ChipViewModel(text: "Aussprache"),
        ChipViewModel(text: "Grammatikbeherrschung"),
        ChipViewModel(text: "Konversationssicherheit")
    ]
    @Published var estimationOfDailyUseTime: [Int] = [5,15,30,60]
    
    private let userDataManager = UserDataManagerImpl()
    
    init(router: Router) {
        self.router = router
    }
    
    func didTapChipView(_ tappedChipVM: ChipViewModel) {
        tappedChipVM.isSelected.toggle()
    }
    
    func saveUserData() async {
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

        print(name)
        print(learningGoals.description)
        print(interestsArray)
        print(estimationOfDailyUse)

        let data = ProfileData(
            name: name,
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
