import Quick
import Nimble
@testable import github

class IssueSpec: QuickSpec {
    override func spec() {
        describe("Issue") {
            var sut: Issue!
            let json = ["title" : "bananas",
                "user" : [
                    "login" : "john",
                ],
                "createdAt" : "2008-11-14T03:57:43Z"] as [String : Any]
            beforeEach {
                sut = Issue.fromJSON(json)
            }
            
            context("when deserializing") {
                it("should have valid title") {
                    expect(sut.title) == "bananas"
                }
                
                it("should have valid author") {
                    expect(sut.author) == "john"
                }
                
                it("should have valid creation date") {
                    
                    let components = NSDateComponents()
                    components.day = 14
                    components.month = 11
                    components.year = 2008
                    components.hour = 3
                    components.minute = 57
                    components.second = 43
                    
                    let date = NSCalendar.currentCalendar.dateFromComponents(components)
                    expect(sut.date) == date
                }
            }
        }
    }
}
