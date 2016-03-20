import Quick
import Nimble
import RxBlocking
import RxSwift
import RxCocoa
import RxTests
import Moya
@testable import github

class RepositoryViewModelSpec: QuickSpec {
    override func spec() {
        var sut: RepositoryViewModel!
        var scheduler: TestScheduler!
        var disposeBag: DisposeBag!
        var repo: Repo!
        
        beforeEach {
            scheduler = TestScheduler(initialClock: 0)
            repo = Repo(id: 10, createdAt: NSDate(), fullName: "org/repo", description: "swift repo", language: nil, stargazers: 10, forks: 12, type: .Source, owner: Owner(id: 10, name: "me", fullName: "me"))
            driveOnScheduler(scheduler) {
                sut = RepositoryViewModel(provider: RxMoyaProvider(stubClosure: MoyaProvider.ImmediatelyStub), repo: repo)
            }
            disposeBag = DisposeBag()
        }
        
        afterEach {
            scheduler = nil
            sut = nil
            disposeBag = nil
        }
        
        it("returns full name") {
            expect(sut.fullName) == "org/repo"
        }
        
        it("returns description") {
            expect(sut.description) == "swift repo"
        }
        
        it("returns number of forks") {
            expect(sut.forksCounts) == "12"
        }
        
        it("returns number of stars") {
            expect(sut.starsCount) == "10"
        }
        
        it("fetches user data and return last pull request, no issues and no commits") {
            let observer = scheduler.createObserver([RepositorySectionViewModel])
            
            scheduler.scheduleAt(100) {
                sut.dataObservable.asObservable().subscribe(observer).addDisposableTo(disposeBag)
            }
            
            scheduler.start()
            
            let result = observer.events.first.map { event in
                event.value.element!
            }
            
            let resultCount = result!.count
            let pullRequestTitle = result!.first!.items.first!.title
            
            expect(resultCount) == 1
            expect(pullRequestTitle) == "Avatar"
        }
    }
}
