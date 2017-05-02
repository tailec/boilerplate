import Foundation
import SwiftyJSON

struct Commit {
    let message: String
    let author: String
    let date: Date
}

extension Commit: Decodable {
    static func fromJSON(_ json: AnyObject) -> Commit {
        let json = JSON(json)
        
        let message = json["commit"]["message"].stringValue
        let author = json["committer"]["login"].stringValue
        let date = Date(fromGitHubString: json["createdAt"].stringValue)
        
        return Commit(message: message, author: author, date: date)
    }
}
