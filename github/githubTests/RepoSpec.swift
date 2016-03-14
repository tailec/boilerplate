import Quick
import Nimble
@testable import github

class RepoSpec: QuickSpec {
    override func spec() {
        describe("Repo") {
            var sut: Repo!
            let json = ["id" : 10,
                "created_at" : "2008-11-14T03:57:43Z",
                "full_name" : "coolrepo",
                "description" : "nice repo",
                "stargazers_count" : 42,
                "forks" : 1,
                "fork" : false]
            beforeEach {
                sut = Repo.fromJSON(json)
            }
            
            context("when deserializing") {
                it("should have valid id") {
                    expect(sut.id) == 10
                }
                it("should have valid creation date") {
                    
                    let components = NSDateComponents()
                    components.day = 14
                    components.month = 11
                    components.year = 2008
                    components.hour = 3
                    components.minute = 57
                    components.second = 43
                    
                    let date = NSCalendar.currentCalendar().dateFromComponents(components)
                    expect(sut.createdAt) == date
                }
                it("should have valid full name") {
                    expect(sut.fullName) == "coolrepo"
                }
                it("should have valid description") {
                    expect(sut.description) == "nice repo"
                }
                it("should have valid number of stars") {
                    expect(sut.stargazers) == 42
                }
                it("should have valid number of forks") {
                    expect(sut.forks) == 1
                }
                it ("should have valid type") {
                    expect(sut.type) == .Source
                }
            }
        }
    }
}
