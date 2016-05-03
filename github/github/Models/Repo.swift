import Foundation
import SwiftyJSON

struct Repo {
    let id: Int
    let createdAt: NSDate
    let fullName: String
    let description: String
    let language: String?
    let stargazers: Int
    let forks: Int
    let type: UserRepoType?
    let owner: Owner
}

extension Repo: Decodable {
    static func fromJSON(json: AnyObject) -> Repo {
        let json = JSON(json)
        
        let id = json["id"].intValue
        let createdAt = NSDate(fromGitHubString: json["created_at"].stringValue)
        let fullName = json["full_name"].stringValue
        let description = json["description"].stringValue
        let language = json["language"].string
        let stargazers = json["stargazers_count"].intValue
        let forks = json["forks"].intValue
        let type = json["fork"].boolValue ? UserRepoType.Fork : UserRepoType.Source
        let owner = Owner.fromJSON(json["onwer"].object)
        
        return Repo(id: id,
            createdAt: createdAt,
            fullName: fullName,
            description: description,
            language: language,
            stargazers: stargazers,
            forks: forks,
            type: type,
            owner: owner)
    }
}

enum UserRepoType  {
    case Fork
    case Source
}

extension UserRepoType: Equatable {}

func == (lhs: UserRepoType, rhs: UserRepoType) -> Bool {
    switch (lhs,rhs) {
    case (.Fork, .Fork):
        return true
    case (.Source, .Source):
        return true
    default:
        return false
    }
}
