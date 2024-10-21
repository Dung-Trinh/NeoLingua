import Foundation
import CoreLocation
import FirebaseDatabase
import FirebaseCore
import FirebaseFirestore
import GooglePlaces
import Alamofire
import SwiftOpenAI

protocol LearningOverviewPageView: ObservableObject {
    func getLocation()
    func fetchLocation() async throws
    func startChat() async
    func startChatWithAssistant() async
}

class LearningOverviewPageViewImpl: LearningOverviewPageView {
    private var listenerRegistration: ListenerRegistration?
    private var placesClient = GMSPlacesClient.shared()
    var messageText = ""
    var functionCallOutput = ""
    var toolOuptutMessage = ""
    
    func getLocation() {
        let locationManager = LocationManager()
        locationManager.checkLocationAuthorization()
        
        let locationManager2 = CLLocationManager()
        locationManager2.requestAlwaysAuthorization()
        
        let placesClient = GMSPlacesClient.shared()
        let fields: GMSPlaceField = [.name, .coordinate]
        
        placesClient.findPlaceLikelihoodsFromCurrentLocation(
            withPlaceFields: fields,
            callback: {
                (placeLikelihoodList: Array<GMSPlaceLikelihood>?, error: Error?) in
                if let error = error {
                    print("An error occurred: \(error.localizedDescription)")
                    return
                }
                
                if let placeLikelihoodList = placeLikelihoodList {
                    for likelihood in placeLikelihoodList {
                        let place = likelihood.place
                        print("Current Place name \(String(describing: place.name)) at likelihood \(likelihood.likelihood)")
                        print("Current PlaceID \(String(describing: place.placeID))")
                    }
                }
            })
    }
    
    func fetchLocation() async throws {}
    
    func startChat() async {
        let apiKey = ProdENV().OPENAI_KEY
        let service = OpenAIServiceFactory.service(apiKey: apiKey)
        
        let stepSchema = JSONSchema(
            type: .object,
            properties: [
                "explanation": JSONSchema(type: .string),
                "output": JSONSchema(
                    type: .string)
            ],
            required: ["explanation", "output"],
            additionalProperties: false
        )
                
        let stepsArraySchema = JSONSchema(type: .array, items: stepSchema)
        let finalAnswerSchema = JSONSchema(type: .string)
        let mathResponseSchema = JSONSchema(
            type: .object,
            properties: [
                "steps": stepsArraySchema,
                "final_answer": finalAnswerSchema
            ],
            required: ["steps", "final_answer"],
            additionalProperties: false
        )

        let tool = ChatCompletionParameters.Tool(
            function: .init(
                name: "math_response",
                strict: true,
                description: "Solves a mathematical equation and provides a step-by-step explanation along with the final answer.",
                parameters: mathResponseSchema
            )
        )
        
        let prompt = "solve 8x + 31 = 2"
        let systemMessage = ChatCompletionParameters.Message(role: .system, content: .text("You are a math tutor. Please solve mathematical problems step by step."))
        let userMessage = ChatCompletionParameters.Message(role: .user, content: .text(prompt))
        let parameters = ChatCompletionParameters(
            messages: [systemMessage, userMessage],
            model: .gpt4o20240806,
            tools: [tool]
        )
        
        do {
            let chat = try await service.startChat(parameters: parameters)
            let choices = chat.choices
            if let firstChoice = choices.first {
                if let toolCall = firstChoice.message.toolCalls?.first {
                    let arguments = toolCall.function.arguments
                    print("Tool Call Arguments: \(arguments)")
                    
                    if let data = arguments.data(using: .utf8) {
                        do {
                            let mathResponse = try JSONDecoder().decode(MathResponse.self, from: data)
                            print("steps:")
                            for step in mathResponse.steps {
                                print("explanation: \(step.explanation), output: \(step.output)")
                            }
                            print("final_answer: \(mathResponse.final_answer)")
                            
                        } catch {
                            print("decode error: \(error)")
                        }
                    }
                }
            }
        } catch {
            print("err: \(error.localizedDescription)")
        }
    }
    
    func startChatWithAssistant() async {
        let apiKey = ProdENV().OPENAI_KEY
        let service = OpenAIServiceFactory.service(apiKey: apiKey)
        let assistantID = "asst_zc4v0imkpRgFzzvGmsBKqNzd"
        let threadID = "thread_vej06HcC683dGXcLYYYe8QL4"
        let prompt = "solve 1 - 2 x 50 = y"
        do {
            let parameters = MessageParameter(role: .user, content: prompt)
            try await service.createMessage(threadID: threadID, parameters: parameters)
            let parameters2 = RunParameter(assistantID: assistantID)
//            let run = try await service.createRun(threadID: threadID, parameters: parameters2)
            
           let stream = try await service.createRunStream(threadID: threadID, parameters: parameters2)
           for try await result in stream {
              
              switch result {
              case .threadMessageDelta(let messageDelta):
                    let content = messageDelta.delta.content.first
                    switch content {
                    case .imageFile, nil:
                       break
                    case .text(let textContent):
                       messageText += textContent.text.value
                    }
              case .threadRunStepDelta(let runStepDelta):
                    let toolCall = runStepDelta.delta.stepDetails.toolCalls?.first?.toolCall
                    switch toolCall {
                    case .codeInterpreterToolCall(let toolCall):
                       toolOuptutMessage += toolCall.input ?? ""
                    case .fileSearchToolCall(let toolCall):
                       print("PROVIDER: File search tool call \(toolCall)")
                    case .functionToolCall(let toolCall):
                       functionCallOutput += toolCall.arguments
                    case nil:
                       print("PROVIDER: tool call nil")
                    }
              case .threadRunCompleted(let runObject):
                 print("PROVIDER: the run is completed - \(runObject)")
              default: break
              }
           }
        }  catch {
           print("THREAD ERROR: \(error)")
        }
        print("messageText ", messageText)
    }
}

// Datenmodelle für die API-Antwort
//struct LocationResponse: Codable {
//    let location: Location
//    let accuracy: Double
//}

//struct Location: Codable {
//    let lat: Double
//    let lng: Double
//}

struct MathStep: Codable {
    let explanation: String
    let output: String
}

struct MathResponse: Codable {
    let steps: [MathStep]
    let final_answer: String
}
