import Foundation

struct Token {
    var token: String? {
        get {
            return userDefaults.stringForKey(UserDefaultsKeys.Token.rawValue)
        }
        set {
            userDefaults.setObject(newValue, forKey: UserDefaultsKeys.Token.rawValue)
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
    
    private let userDefaults: NSUserDefaults
    
    private enum UserDefaultsKeys: String {
        case Token = "TokenKey"
    }
    
    init(userDefaults: NSUserDefaults) {
        self.userDefaults = userDefaults
    }
    init() {
        self.userDefaults = NSUserDefaults.standardUserDefaults()
    }
}