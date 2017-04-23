import Foundation
import SwiftyJSON

struct Repo {
    let id: Int
    let createdAt: Date
    let fullName: String
    let description: String
    let language: String?
    let stargazers: Int
    let forks: Int
    let type: UserRepoType?
    let owner: Owner
}

extension Repo: Decodable {
    static func fromJSON(_ json: AnyObject) -> Repo {
        let json = JSON(json)
        
        let id = json["id"].intValue
        let createdAt = Date(fromGitHubString: json["created_at"].stringValue)
        let fullName = json["full_name"].stringValue
        let description = json["description"].stringValue
        let language = json["language"].string
        let stargazers = json["stargazers_count"].intValue
        let forks = json["forks"].intValue
        let type = json["fork"].boolValue ? UserRepoType.fork : UserRepoType.source
        let owner = Owner.fromJSON(json["onwer"].object as AnyObject)
        
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
    case fork
    case source
}

extension UserRepoType: Equatable {}

func == (lhs: UserRepoType, rhs: UserRepoType) -> Bool {
    switch (lhs,rhs) {
    case (.fork, .fork):
        return true
    case (.source, .source):
        return true
    default:
        return false
    }
}
