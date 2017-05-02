import Foundation

enum GithubError: Error {
    case notAuthenticated
    case rateLimitExceeded
    case wrongJSONParsing
    case generic
}
