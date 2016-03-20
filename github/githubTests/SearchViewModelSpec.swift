import Quick
import Nimble
import RxBlocking
import RxSwift
import RxCocoa
import RxTests
import Moya
@testable import github

class SearchViewModelSpec: QuickSpec {
    override func spec() {
        var sut: SearchViewModel!
        var scheduler: TestScheduler!
        var disposeBag: DisposeBag!
        
        beforeEach {
            scheduler = TestScheduler(initialClock: 0)
            driveOnScheduler(scheduler) {
                sut = SearchViewModel(provider: RxMoyaProvider(stubClosure: MoyaProvider.ImmediatelyStub))
            }
            disposeBag = DisposeBag()
        }
        
        afterEach {
            scheduler = nil
            sut = nil
            disposeBag = nil
        }
        
        it ("returns valid title") {
            expect(sut.title) == "Search"
        }
        
    }
}
