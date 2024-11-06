import Foundation

extension UserDefaults {
    private enum Keys {
        static let selectedLevel = "selectedLevel"
        static let isUserLoggedIn = "isUserLoggedIn"
    }

    func setLevelOfLanguage(_ level: LevelOfLanguage) {
        set(level.rawValue, forKey: Keys.selectedLevel)
    }

    func getLevelOfLanguage() -> LevelOfLanguage? {
        guard let rawValue = string(forKey: Keys.selectedLevel) else { return nil }
        return LevelOfLanguage(rawValue: rawValue)
    }
    
    func setUserLoggedIn(_ isLoggedIn: Bool) {
        set(isLoggedIn, forKey: Keys.isUserLoggedIn)
    }
    
    func isUserLoggedIn() -> Bool {
        return bool(forKey: Keys.isUserLoggedIn)
    }
}
