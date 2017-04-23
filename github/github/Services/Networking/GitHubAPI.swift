import Foundation
import Moya
import RxSwift

let GitHubProvider = RxMoyaProvider<GitHub>(endpointClosure: endpointClosure)

public enum GitHub {
    case token(username: String, password: String)
    case repoSearch(query: String)
    case trendingReposSinceLastWeek
    case repo(owner: String, repoName: String)
    case repoReadMe(owner: String, repoName: String)
    case pulls(onwer: String, repo: String)
    case issues(onwer: String, repo: String)
    case commits(onwer: String, repo: String)
}

extension GitHub: TargetType {
    public var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }

    public var path: String {
        switch self {
        case .token(_, _):
            return "/authorizations"
        case .repoSearch(_),
             .trendingReposSinceLastWeek:
            return "/search/repositories"
        case .repo(let owner, let repoName):
            return "/repos\(owner)/\(repoName)"
        case .repoReadMe(let owner, let repoName):
            return "/repos\(owner)/\(repoName)/readme"
        case .pulls(let owner, let repo):
            return "/repos\(owner)/\(repo)/pulls"
        case .issues(let owner, let repo):
            return "/repos\(owner)/\(repo)/issues"
        case .commits(let owner, let repo):
            return "/repos\(owner)/\(repo)/commits"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .token(_, _):
            return .post
        case .repoSearch(_),
             .trendingReposSinceLastWeek,
             .repo(_,_),
             .repoReadMe(_,_),
             .pulls(_,_),
             .issues(_,_),
             .commits(_,_):
            return .get
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .token(_, _):
            return [
                "scopes": ["public_repo", "user"],
                "note": "Ori iOS app (\(Date()))"
            ]
        case .repo(_,_),
        .repoReadMe(_,_),
        .pulls,
        .issues,
        .commits:
            return nil
        case .repoSearch(let query):
            return ["q": query.URLEscapedString as AnyObject]
        case .trendingReposSinceLastWeek:
            return ["q" : "created:>" + Date().lastWeek(),
                    "sort" : "stars",
                    "order" : "desc"]
        }
    }

    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    public var sampleData: Data {
        switch self {
        case .token(_, _):
            return "Half measures are as bad as nothing at all.".data(using: String.Encoding.utf8)!
        case .repoSearch(_):
            return StubResponse.fromJSONFile("SearchResponse")
        case .trendingReposSinceLastWeek:
            return StubResponse.fromJSONFile("SearchResponse")
        case .repo(_,_):
            return "Half measures are as bad as nothing at all.".data(using: String.Encoding.utf8)!
        case .repoReadMe(_,_):
            return "Half measures are as bad as nothing at all.".data(using: String.Encoding.utf8)!
        case .pulls(_,_):
            return "[{\"title\": \"Avatar\", \"user\": { \"login\": \"me\" }, \"createdAt\": \"2011-01-26T19:01:12Z\" }]".data(using: String.Encoding.utf8)!
        case .issues(_,_):
            return "Half measures are as bad as nothing at all.".data(using: String.Encoding.utf8)!
        case .commits(_,_):
            return "Half measures are as bad as nothing at all.".data(using: String.Encoding.utf8)!
        }
    }

    public var task: Task {
        return .request
    }
}

var endpointClosure = { (target: GitHub) -> Endpoint<GitHub> in
    let url = target.baseURL.appendingPathComponent(target.path).absoluteString
    let endpoint: Endpoint<GitHub> = Endpoint(url: url, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
    switch target {
    case .token(let userString, let passwordString):
        let credentialData = "\(userString):\(passwordString)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        return endpoint.adding(newHTTPHeaderFields: ["Authorization": "Basic \(base64Credentials)"])
            .adding(newParameterEncoding: JSONEncoding.default)
    default:
        let appToken = Token()
        guard let token = appToken.token else {
            return endpoint
        }
        return endpoint.adding(newHTTPHeaderFields: ["Authorization": "token \(token)"])
    }
}

private extension String {
    var URLEscapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    }
}
