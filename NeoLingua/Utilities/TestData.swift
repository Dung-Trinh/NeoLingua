import Foundation
import GoogleMaps

class TestData {
    static let vocabularyTasks: [VocabularyExercise] = [
//        ChooseWordExercise(
//            id: "3",
//            type: .multipleChoice,
//            question: "One of the main attractions of the Warmer Damm is its beautiful ________.",
//            answer: "gardens",
//            translation: "Eine der Hauptattraktionen des Warmer Damm sind seine schönen Gärten.",
//            selectableWords: [
//                "gardens",
//                "lakes",
//                "buildings",
//                "restaurants"
//            ]
//        ),
//        WriteWordExercise(
//            id: "1",
//            type: .fillInTheBlanks,
//            question: "The Warmer Damm park is a popular place for a ________ in Wiesbaden.",
//            answer: "walk",
//            translation: "Der Warmer Damm Park ist ein beliebter Ort für einen Spaziergang in Wiesbaden."
//        ),
//        SentenceBuildingExercise(
//            id: "2",
//            type: .sentenceAssembly,
//            question: "Assemble the sentence: is / Wiesbaden / located / Warmer Damm / in / Park / the",
//            answer: "The Warmer Damm Park is located in Wiesbaden.",
//            translation: "Der Warmer Damm Park befindet sich in Wiesbaden.",
//            sentenceComponents: [
//                "is",
//                "Wiesbaden",
//                "located",
//                "Warmer Damm",
//                "in",
//                "Park",
//                "the"
//            ]
//        ),
        ChooseWordExercise(
            id: "3",
            type: .multipleChoice,
            question: "One of the main attractions of the Warmer Damm is its beautiful ________.",
            answer: "gardens",
            translation: "Eine der Hauptattraktionen des Warmer Damm sind seine schönen Gärten.",
            selectableWords: [
                "gardens",
                "lakes",
                "buildings",
                "restaurants"
            ]
        )
    ]
    static let pointOfInterestSpots: [PointOfInterest] = [
        PointOfInterest(name: "Spielbank Wiesbaden", coordinate: CLLocationCoordinate2D(latitude: 50.084722, longitude: 8.247252)),
        PointOfInterest(name: "Kurpark Wiesbaden", coordinate: CLLocationCoordinate2D(latitude: 50.084510, longitude: 8.251848)),
        PointOfInterest(name: "Warmer Damm", coordinate: CLLocationCoordinate2D(latitude: 50.082465, longitude: 8.246972))
    ]
    static let scavengerHunt: ScavengerHunt = ScavengerHunt(
        id: "1",
        introduction: "Welcome to the Wiesbaden themed English learning scavenger hunt! Explore the city's landmarks while improving your language skills.",
        taskLocations: [
            TaskLocation(
                name: "Spielbank Wiesbaden",
                type: "casino",
                location: Location(latitude: 50.0847775, longitude: 8.2471916),
                taskPrompt: TaskPrompt(
                    vocabularyTraining: "Create vocabulary exercises related to the Spielbank Wiesbaden incorporating concepts such as 'gambling', 'roulette', 'jackpot', and 'casino'.",
                    listeningComprehension: "Design a listening exercise that involves a visitor at Spielbank Wiesbaden asking about the rules of a specific game.",
                    conversationSimulation: "Location: Casino. The conversation could be between a first-time visitor asking the croupier about how to play a specific game."
                    
                ),
                photoClue: "Seek something known for 'luck' in the vicinity. This item shines bright.",
                photoObject: "Casino Signage"
            ),
            TaskLocation(
                name: "Bowling Green, Wiesbaden",
                type: "park",
                location: Location(latitude: 50.0847005, longitude: 8.2457267),
                taskPrompt: TaskPrompt(
                    vocabularyTraining: "Develop vocabulary exercises that emphasize the natural environment at Bowling Green, including words such as 'fountain', 'lawn', 'bench', and 'statue'.",
                    listeningComprehension: "Create a listening comprehension task where someone describes a relaxing afternoon spent at Bowling Green, Wiesbaden.",
                    conversationSimulation: "Location: Park. A conversation between friends planning a picnic and discussing their favorite spots in the park."
                    
                ),
                photoClue: "Find the symbol of tranquility, where water flows endlessly.",
                photoObject: "Fountain"
            )
        ]
    )
    static let imageBasedTask: ImageBasedTask = ImageBasedTask(
        id: "f28acc6b-fd5c-4438-b5bc-ba60e16a426c",
        title: "Lemon Tree",
        description: "The image showcases a branch of a lemon tree with green leaves and one yellowing leaf. The focus on foliage suggests a natural setting, potentially in a home garden or a botanical environment.",
        taskPrompt: TaskPrompt(
            vocabularyTraining: "Create exercises involving plant vocabulary and lemon tree care, including words like 'leaves', 'branch', 'photosynthesis', 'pruning'.",
            listeningComprehension: "Create a listening exercise about citrus fruits and the importance of lemon trees in horticulture.",
            conversationSimulation: "Location: Home garden; the conversation could be between a gardener explaining lemon tree maintenance to a homeowner."
        )
    )
}
