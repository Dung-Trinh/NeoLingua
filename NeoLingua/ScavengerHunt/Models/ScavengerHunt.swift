import Foundation

struct ScavengerHunt: Codable, Identifiable {
    let id: String
    let title: String
    let introduction: String
    var taskLocations: [TaskLocation]
    var scavengerHuntState: ScavengerHuntState? = nil
    
    func isHuntComplete() -> Bool {
        guard let scavengerHuntState = scavengerHuntState else {
            return false
        }
        let isDone = true
        for performance in scavengerHuntState.locationTaskPerformance {
            if performance.performance.didFoundObject == nil {
                return false
            }
        }
        return isDone
    }
}

struct ScavengerHuntResponse: Codable{
    let scavengerHunt: ScavengerHunt
}
