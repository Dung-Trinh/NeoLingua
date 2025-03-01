import Foundation

struct ScavengerHuntState: Codable {
    let scavengerHuntId: String
    let scavengerHuntTitle: String
    let userId: String
    var isCompleted: Bool
    var locationTaskPerformance: [LocationTaskPerformance]
    
    init(scavengerHunt: ScavengerHunt) {
        self.scavengerHuntId = scavengerHunt.id
        self.scavengerHuntTitle = scavengerHunt.title
        userId = UserDefaults.standard.string(forKey: "userId") ?? ""
        isCompleted = false
        locationTaskPerformance = []
        for location in scavengerHunt.taskLocations {
            var performance = UserTaskPerformance(userId: userId,taskId: "")
            let performanceParameter = TaskPerformancetParameter()
            if location.taskPrompt.vocabularyTraining != nil {
                performance.vocabularyTraining = performanceParameter
            }
            
            if location.taskPrompt.listeningComprehension != nil {
                performance.listeningComprehension = performanceParameter
            }
            
            if location.taskPrompt.conversationSimulation != nil {
                performance.conversationSimulation = performanceParameter
            }
            
            var locationpPerformance = LocationTaskPerformance(
                locationId: location.id,
                locationName: location.name,
                performance: performance
            )
            locationpPerformance.performance.taskTypes = [.conversationSimulation,.listeningComprehension,.vocabularyTraining]
            locationTaskPerformance.append(locationpPerformance)
        }
    }
}
