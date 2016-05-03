import Foundation
import Moya
import RxSwift

let GitHubProvider = RxMoyaProvider<GitHub>(endpointClosure: endpointClosure)

public enum GitHub {
    case Token(username: String, password: String)
    case RepoSearch(query: String)
    case TrendingReposSinceLastWeek
    case Repo(owner: String, repoName: String)
    case RepoReadMe(owner: String, repoName: String)
    case Pulls(onwer: String, repo: String)
    case Issues(onwer: String, repo: String)
    case Commits(onwer: String, repo: String)
}

extension GitHub: TargetType {
    public var baseURL: NSURL { return NSURL(string: "https://api.github.com")! }
    
    public var path: String {
        switch self {
        case .Token(_, _):
            return "/authorizations"
        case .RepoSearch(_),
        .TrendingReposSinceLastWeek:
            return "/search/repositories"
        case Repo(let owner, let repoName):
            return "/repos\(owner)/\(repoName)"
        case RepoReadMe(let owner, let repoName):
            return "/repos\(owner)/\(repoName)/readme"
        case Pulls(let owner, let repo):
            return "/repos\(owner)/\(repo)/pulls"
        case Issues(let owner, let repo):
            return "/repos\(owner)/\(repo)/issues"
        case Commits(let owner, let repo):
            return "/repos\(owner)/\(repo)/commits"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .Token(_, _):
            return .POST
        case .RepoSearch(_),
        .TrendingReposSinceLastWeek,
        .Repo(_,_),
        .RepoReadMe(_,_),
        .Pulls(_,_),
        .Issues(_,_),
        .Commits(_,_):
            return .GET
        }
    }
    
    public var parameters: [String: AnyObject]? {
        switch self {
        case .Token(_, _):
            return [
                "scopes": ["public_repo", "user"],
                "note": "Ori iOS app (\(NSDate()))"
            ]
        case Repo(_,_),
        RepoReadMe(_,_),
        Pulls,
        Issues,
        Commits:
            return nil
        case .RepoSearch(let query):
            return ["q": query.URLEscapedString]
        case .TrendingReposSinceLastWeek:
            return ["q" : "created:>" + NSDate().lastWeek(),
                "sort" : "stars",
                "order" : "desc"]
        }
    }
    
    public var sampleData: NSData {
        switch self {
        case .Token(_, _):
            return "Half measures are as bad as nothing at all.".dataUsingEncoding(NSUTF8StringEncoding)!
        case .RepoSearch(_):
            return StubResponse.fromJSONFile("SearchResponse")
        case .TrendingReposSinceLastWeek:
            return StubResponse.fromJSONFile("SearchResponse")
        case .Repo(_,_):
            return "Half measures are as bad as nothing at all.".dataUsingEncoding(NSUTF8StringEncoding)!
        case .RepoReadMe(_,_):
            return "Half measures are as bad as nothing at all.".dataUsingEncoding(NSUTF8StringEncoding)!
        case .Pulls(_,_):
            return "[{\"title\": \"Avatar\", \"user\": { \"login\": \"me\" }, \"createdAt\": \"2011-01-26T19:01:12Z\" }]".dataUsingEncoding(NSUTF8StringEncoding)!
        case .Issues(_,_):
            return "Half measures are as bad as nothing at all.".dataUsingEncoding(NSUTF8StringEncoding)!
        case .Commits(_,_):
            return "Half measures are as bad as nothing at all.".dataUsingEncoding(NSUTF8StringEncoding)!
        }
    }
}

var endpointClosure = { (target: GitHub) -> Endpoint<GitHub> in
    let url = target.baseURL.URLByAppendingPathComponent(target.path).absoluteString
    let endpoint: Endpoint<GitHub> = Endpoint(URL: url, sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
    switch target {
    case .Token(let userString, let passwordString):
        let credentialData = "\(userString):\(passwordString)".dataUsingEncoding(NSUTF8StringEncoding)!
        let base64Credentials = credentialData.base64EncodedStringWithOptions([])
        return endpoint.endpointByAddingHTTPHeaderFields(["Authorization": "Basic \(base64Credentials)"])
            .endpointByAddingParameterEncoding(.JSON)
    default:
        let appToken = Token()
        guard let token = appToken.token else {
            return endpoint
        }
        return endpoint.endpointByAddingHTTPHeaderFields(["Authorization": "token \(token)"])
    }
}

private extension String {
    var URLEscapedString: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
    }
}
