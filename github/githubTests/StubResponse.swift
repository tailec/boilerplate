import Foundation

class StubResponse {
    static func fromJSONFile(fileName: String) -> NSData {
        guard let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "json") else {
            fatalError("Invalid path for json file")
        }
        guard let data = NSData(contentsOfFile: path) else {
            fatalError("Invalid data from json file")
        }
        return data
    }
}