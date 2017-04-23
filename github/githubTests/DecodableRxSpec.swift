import Quick
import Nimble
import Moya
import SwiftyJSON
import RxSwift
import RxBlocking
@testable import github

private struct ModelMock {
    let something: String
}

extension ModelMock: Decodable {
    static func fromJSON(_ json: AnyObject) -> ModelMock {
        let json = JSON(json)
        let something = json["something"].stringValue
        return ModelMock(something: something)
    }
}

class DecodableRxSpec: QuickSpec {
    override func spec() {
        describe("Decodable") {
            
            it("should map to one model") {
                let json = "{\"something\": \"else\"}"
                
                let sut = try! Observable.just(Response(statusCode: 200, data: json.data(using: String.Encoding.utf8)!))
                    .mapToModel(ModelMock.self)
                    .toBlocking()
                    .first()
                
                expect(sut!.something) == "else"
            }
            
            it("should map to multiple models") {
                let json = "[{\"something\": \"else\"}, {\"something\": \"oops\"}]"
                
                let sut = try! Observable.just(Response(statusCode: 200, data: json.data(using: String.Encoding.utf8)!))
                    .mapToModels(ModelMock.self)
                    .toBlocking()
                    .first()
                
                expect(sut!.count) == 2
                expect(sut!.first!.something) == "else"
            }
            
            it("should map to multiple models with provided array root key") {
                let json = "{\"items\": [{\"something\": \"else\"}, {\"something\": \"oops\"}]}"
                
                let sut = try! Observable.just(Response(statusCode: 200, data: json.data(using: String.Encoding.utf8)!))
                    .mapToModels(ModelMock.self, arrayRootKey: "items")
                    .toBlocking()
                    .first()
                
                expect(sut!.count) == 2
                expect(sut!.first!.something) == "else"
            }
        }
    }
}
