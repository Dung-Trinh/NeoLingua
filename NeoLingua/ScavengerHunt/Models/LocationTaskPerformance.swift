import Foundation

struct LocationTaskPerformance: Codable{
    let locationId: String
    let locationName: String
    var performance: UserTaskPerformance
    
    
    func getPointsForLocationPerformance() -> Double {
        let vocabularyPoints = Double(((performance.vocabularyTraining?.result ?? 0) * 100) * 15 / 100)
        let listeningComprehensionPoints = Double(((performance.listeningComprehension?.result ?? 0) * 100) * 30 / 100).twoDecimals
        let conversationSimulationPoints = Double(((performance.conversationSimulation?.result ?? 0) * 100) * 40 / 100).twoDecimals
        let searchingTheObjectPoints = Double(((performance.searchingTheObject?.result ?? 0) * 100) * 15 / 100).twoDecimals
        return (vocabularyPoints + listeningComprehensionPoints + conversationSimulationPoints + searchingTheObjectPoints).twoDecimals
    }
}
