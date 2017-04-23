import Foundation

struct Token {
    var token: String? {
        get {
            return userDefaults.string(forKey: UserDefaultsKeys.Token.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultsKeys.Token.rawValue)
            userDefaults.synchronize()
        }
    }
    
    var tokenExists: Bool {
        if let _ = token {
            return true
        } else {
            return false
        }
    }
    
    fileprivate let userDefaults: UserDefaults
    
    fileprivate enum UserDefaultsKeys: String {
        case Token = "TokenKey"
    }
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    init() {
        self.userDefaults = UserDefaults.standard
    }
}
