import Foundation

protocol APIKeyable {
    var TESTKEY: String { get }
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
    var TESTKEY: String {
        dict.object(forKey: "TESTKEY") as? String ?? ""
    }
    
    init() {
        super.init(resourceName: "Env-Properties")
    }
}
