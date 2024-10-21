import Foundation

protocol ScavengerHuntOverviewPageViewModel: ObservableObject {

}

class ScavengerHuntOverviewPageViewModelImpl: ScavengerHuntOverviewPageViewModel {
    let scavengerHuntManager = ScavengerHuntManager()
    @Published var currentScavengerHunt: ScavengerHunt?
    
    func fetchScavengerHunt() async {
        do {
            currentScavengerHunt = try await scavengerHuntManager.fetchScavengerHunt()
        } catch {
            print("fetchScavengerHunt error: ", error.localizedDescription)
        }
    }
}
