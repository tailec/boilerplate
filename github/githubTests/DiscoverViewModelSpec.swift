import Quick
import Nimble
import RxBlocking
import RxSwift
import RxCocoa
import RxTests
import Moya
@testable import github

class DiscoverViewModelSpec: QuickSpec {
    override func spec() {
        var sut: DiscoverViewModel!
        var scheduler: TestScheduler!
        var disposeBag: DisposeBag!
        
        beforeEach {
            scheduler = TestScheduler(initialClock: 0)
            driveOnScheduler(scheduler) {
                sut = DiscoverViewModel(provider: RxMoyaProvider(stubClosure: MoyaProvider.ImmediatelyStub))
            }
            disposeBag = DisposeBag()
        }
        
        afterEach {
            scheduler = nil
            sut = nil
            disposeBag = nil
        }
        
        it ("returns valid title") {
            expect(sut.title) == "Trending"
        }
        
        it("returns one repo when created") {
            let observer = scheduler.createObserver([RepoCellViewModel])
            
            scheduler.scheduleAt(100) {
                sut.results.asObservable().subscribe(observer).addDisposableTo(disposeBag)
            }
            
            scheduler.start()
            
            let results = observer.events.first
                .map { event in
                    event.value.element!.count
                }

            expect(results) == 1
        }
        
        it("fetches repos when triggered refresh") {
            let observer = scheduler.createObserver([RepoCellViewModel])
            
            scheduler.scheduleAt(100) {
                sut.results.asObservable().subscribe(observer).addDisposableTo(disposeBag)
            }
            
            scheduler.scheduleAt(200) {
                sut.triggerRefresh.onNext(())
            }
            
            scheduler.start()
            
            let numberOfCalls = observer.events
                .map { event in
                    event.value.element!.count
                }
                .reduce(0) { $0 + $1 }
            
            expect(numberOfCalls) == 2
        }

        it("sends true when network request is executing and false when it finishes") {
            let observer = scheduler.createObserver(Bool)
            scheduler.scheduleAt(100) {
                sut.executing.asObservable().subscribe(observer).addDisposableTo(disposeBag)
                sut.results.asObservable().subscribe().addDisposableTo(disposeBag)
            }
            
            scheduler.start()
            
            let results = observer.events
                .map { event in
                    event.value.element!
                }
            
            expect(results) == [false, true, false]
        }
        
        xit("returns repository view model when item selected") {
            let observer = scheduler.createObserver(RepositoryViewModel)
            
            scheduler.scheduleAt(100) {
                sut.results.asObservable().subscribe().addDisposableTo(disposeBag)
            }
            
            scheduler.scheduleAt(200) {
                sut.selectedItem.onNext(NSIndexPath(forRow: 0, inSection: 0))
            }
            
            scheduler.scheduleAt(300) {
                sut.selectedViewModel.asObservable().subscribe(observer).addDisposableTo(disposeBag)
            }
            
            scheduler.start()
            
            let result = observer.events.first
                .map { event in
                    event.value.element!
                }
            
            expect(result).notTo(beNil())
        }
    }
}
