import Foundation

protocol APIKeyable {
    var GOOGLE_MAPS_KEY: String { get }
    var OPENAI_KEY: String { get }
    var USER_NAME: String { get }
    var USER_PASSWORD: String { get }

}

class BaseENV {
    let dict: NSDictionary
    
    init(resourceName: String) {
        guard let filePath = Bundle.main.path(forResource: resourceName, ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath) else {
            fatalError("couldn't find  file \((resourceName))")
        }
        self.dict = plist
    }
}


class ProdENV: BaseENV, APIKeyable {
    var GOOGLE_MAPS_KEY: String {
        dict.object(forKey: "GOOGLE_MAPS_KEY") as? String ?? ""
    }
    
    var OPENAI_KEY: String {
        dict.object(forKey: "OPENAI_KEY") as? String ?? ""
    }
    
    var USER_NAME: String {
        dict.object(forKey: "USER_NAME") as? String ?? ""
    }
    
    var USER_PASSWORD: String {
        dict.object(forKey: "USER_PASSWORD") as? String ?? ""
    }
    
    init() {
        super.init(resourceName: "Env-Properties")
    }
}
