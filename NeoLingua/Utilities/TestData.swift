import Foundation
import GoogleMaps

class TestData {
    static let vocabularyTasks: [VocabularyExercise] = [
        WriteWordExercise(
            id: "1",
            type: .fillInTheBlanks,
            question: "The Warmer Damm park is a popular place for a ________ in Wiesbaden.",
            answer: "walk",
            translation: "Der Warmer Damm Park ist ein beliebter Ort für einen Spaziergang in Wiesbaden."
        ),
        SentenceBuildingExercise(
            id: "2",
            type: .sentenceAssembly,
            question: "Assemble the sentence: is / Wiesbaden / located / Warmer Damm / in / Park / the",
            answer: "The Warmer Damm Park is located in Wiesbaden.",
            translation: "Der Warmer Damm Park befindet sich in Wiesbaden.",
            sentenceComponents: [
                "is",
                "Wiesbaden",
                "located",
                "Warmer Damm",
                "in",
                "Park",
                "the"
            ]
        ),
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
}
