import Foundation

protocol Decodable {
    static func fromJSON(json: AnyObject) -> Self
}

extension Decodable {
    static func fromJSONArray(json: [AnyObject]) -> [Self] {
        return json.map { Self.fromJSON($0) }
    }
}