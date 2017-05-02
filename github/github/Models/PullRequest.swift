import Foundation
import SwiftyJSON

struct PullRequest {
    let title: String
    let author: String
    let date: Date
}

extension PullRequest: Decodable {
    static func fromJSON(_ json: AnyObject) -> PullRequest {
        let json = JSON(json)
        
        let title = json["title"].stringValue
        let author = json["user"]["login"].stringValue
        let date = Date(fromGitHubString: json["createdAt"].stringValue)
        
        return PullRequest(title: title, author: author, date: date)
    }
}
