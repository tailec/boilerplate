import Foundation
import SwiftyJSON

struct Issue {
    let title: String
    let author: String
    let date: Date
}

extension Issue: Decodable {
    static func fromJSON(_ json: AnyObject) -> Issue {
        let json = JSON(json)
        
        let title = json["title"].stringValue
        let author = json["user"]["login"].stringValue
        let date = Date(fromGitHubString: json["createdAt"].stringValue)
        
        return Issue(title: title, author: author, date: date)
    }
}
