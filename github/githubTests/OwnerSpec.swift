import Quick
import Nimble
@testable import github

class OwnerSpec: QuickSpec {
    override func spec() {
        describe("Owner") {
            var sut: Owner!
            let json = ["id" : 42,
                "name" : "john",
                "full_name" : "john doe"] as [String : Any]
            beforeEach {
                sut = Owner.fromJSON(json)
            }
            
            context("when deserializing") {
                it("should have valid id") {
                    expect(sut.id) == 42
                }
                
                it("should have valid name") {
                    expect(sut.name) == "john"
                }
                
                it("should have valid full name") {
                    expect(sut.fullName) == "john doe"
                }
            }
        }
    }
}
