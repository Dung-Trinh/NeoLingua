import Foundation
import SwiftOpenAI

class OpenAIServiceProvider {
    static let shared: OpenAIService = {
        let instance = OpenAIServiceFactory.service(apiKey: ProdENV().OPENAI_KEY)
        return instance
    }()
}
