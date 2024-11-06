import Foundation

extension UserDefaults {
    private enum Keys {
        static let selectedLevel = "selectedLevel"
        static let isUserLoggedIn = "isUserLoggedIn"
        static let userId = "userId"
        static let username = "username"
    }

    func setLevelOfLanguage(_ level: LevelOfLanguage) {
        set(level.rawValue, forKey: Keys.selectedLevel)
    }

    func getLevelOfLanguage() -> LevelOfLanguage {
        guard let rawValue = string(forKey: Keys.selectedLevel) else { return LevelOfLanguage.A1 }
        return LevelOfLanguage(rawValue: rawValue) ?? LevelOfLanguage.A1
    }
    
    func setUserLoggedIn(_ isLoggedIn: Bool) {
        set(isLoggedIn, forKey: Keys.isUserLoggedIn)
    }
    
    func isUserLoggedIn() -> Bool {
        return bool(forKey: Keys.isUserLoggedIn)
    }
    
    func getUserId() -> String {
        guard let userId = string(forKey: Keys.userId) else { return ""}
        return userId
    }
    
    func setUsername(_ username: String)  {
        set(username, forKey: Keys.username)
    }
    
    func getUsername() -> String {
        guard let userId = string(forKey: Keys.username) else { return ""}
        return userId
    }
}
