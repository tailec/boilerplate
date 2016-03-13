import Foundation

enum GithubError: ErrorType {
    case NotAuthenticated
    case RateLimitExceeded
    case WrongJSONParsing
    case Generic
}
