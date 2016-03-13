import Foundation
import SwiftyJSON

struct Issue {
    let title: String
    let author: String
    let date: NSDate
}

extension Issue: Decodable {
    static func fromJSON(json: AnyObject) -> Issue {
        let json = JSON(json)
        
        let title = json["title"].stringValue
        let author = json["user"]["login"].stringValue
        let date = NSDate(fromGitHubString: json["createdAt"].stringValue)
        
        return Issue(title: title, author: author, date: date)
    }
}
