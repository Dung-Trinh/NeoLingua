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
        id: UUID().uuidString, 
        title: "Wiesbaden scavenger hunt",
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
    static let listeningExercise: ListeningExercise = ListeningExercise(
        textForSpeech: "This is a listening exercise about general knowledge.",
        listeningQuestions: [
            ListeningQuestion(id: "q1", question: "What is the capital of France?"),
            ListeningQuestion(id: "q2", question: "How many continents are there?"),
            ListeningQuestion(id: "q3", question: "Who was the first man on the moon?")
        ])
    static let listeningExerciseEvaluation: ListeningTaskEvaluation = .init(evaluatedQuestions: [
        EvaluatedQuestion(
            id: "q1",
            question: "What is the capital of France?",
            isAnswerRight: true,
            rightAnswer: "Paris",
            suggestions: ["Paris", "London", "Berlin"]
        ),
        EvaluatedQuestion(
            id: "q2",
            question: "What is 2 + 2?",
            isAnswerRight: true,
            rightAnswer: "4",
            suggestions: ["3", "4", "5"]
        ),
        EvaluatedQuestion(
            id: "q3",
            question: "What is the largest ocean?",
            isAnswerRight: false,
            rightAnswer: "Pacific",
            suggestions: ["Atlantic", "Indian", "Pacific"]
        )
    ])
    static let conversationEvaluation: ConversationEvaluation = ConversationEvaluation(
        grammar: "The grammar usage is good, but there were a few minor mistakes.",
        wordChoice: "Word choice was appropriate and natural.",
        structure: "The sentence structure was clear and followed normal patterns.",
        tasksCompletion: [
            TaskCompletion(
                task: "Translate the sentence correctly",
                isCompleted: true,
                suggestion: nil
            ),
            TaskCompletion(
                task: "Use proper grammar in the response",
                isCompleted: false,
                suggestion: "Improve the verb usage in future exercises."
            ),
            TaskCompletion(
                task: "Choose the correct word in context",
                isCompleted: true,
                suggestion: nil
            )
        ],
        rating: 7.6
    )
    static let imageValidationResult: ImageValidationResult = .init(
        isMatching: true,
        reason: "it is true, it is true, it is true, it is true, it is true, it is true",
        confidenceScore: 0.9
    )
    static let roleOptionsResponse: RoleOptionsResponse = RoleOptionsResponse(
        contextDescription: "You are dining at a seafood restaurant known for its fresh catch and elegant atmosphere. The restaurant prides itself on its wide selection of fish dishes and exquisite wine list. As you settle into the cozy setting, you are either ready to place your order as a customer or assist a diner as a server.",
        roleOptions: [
        RoleOption(
            role: "Cashier",
            tasks: [
                "Greet the customer and offer help.",
                "Suggest a combo meal.",
                "Ask if the customer wants to upsize their order."
            ]
        ),
        RoleOption(
            role: "Customer",
            tasks: [
                "Order a main course.",
                "Order a drink.",
                "Ask for something specific like extra sauce or no onions."
            ]
        )
    ])
    static let conversationResponse: ConversationResponse = ConversationResponse(endOfConversation: true, answer: "test done i think so")
    static let conversationIntroResponse: IntroResponse = .init(introText: "You've just entered a McDonald's and are greeted by a friendly cashier behind the counter. There's a digital menu overhead showcasing various options, like the Big Mac meal, Chicken McNuggets, and Quarter Pounder with Cheese. For drinks, you see options like Coke, Sprite, and Iced Tea. As you approach the counter, you begin to decide what you'd like to order. Don't forget, you can ask for modifications, such as extra sauce or no onions.")
}
