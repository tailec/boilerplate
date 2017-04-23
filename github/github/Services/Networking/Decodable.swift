import Foundation

protocol Decodable {
    static func fromJSON(_ json: AnyObject) -> Self
}

extension Decodable {
    static func fromJSONArray(_ json: [AnyObject]) -> [Self] {
        return json.map { Self.fromJSON($0) }
    }
}
