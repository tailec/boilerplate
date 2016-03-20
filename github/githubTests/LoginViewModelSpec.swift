import Quick
import Nimble
import RxBlocking
import RxSwift
import RxCocoa
import RxTests
import Moya
@testable import github

class LoginViewModelSpec: QuickSpec {
    override func spec() {
        var sut: LoginViewModel!
        var scheduler: TestScheduler!
        var disposeBag: DisposeBag!
        
        beforeEach {
            scheduler = TestScheduler(initialClock: 0)
            driveOnScheduler(scheduler) {
                sut = LoginViewModel(provider: RxMoyaProvider(stubClosure: MoyaProvider.ImmediatelyStub))
            }
            disposeBag = DisposeBag()
        }
        afterEach {
            scheduler = nil
            sut = nil
            disposeBag = nil
        }
        
        it("should enable UI elements when valid login credentials are entered") {
            let observer = scheduler.createObserver(Bool)


            scheduler.scheduleAt(100) {
                sut.loginEnabled.asObservable().subscribe(observer).addDisposableTo(disposeBag)

            }
            
            scheduler.scheduleAt(200) {
                sut.username.value = "johny"
                sut.password.value = "yellowpanties"
            }

            scheduler.start()

            let results = observer.events
                .map { event in
                    event.value.element!
            }
            
            expect(results) == [false, false, true]
        }
        
        it("should make network request and return error when valid login credentials are entered") {
            let results = scheduler.createObserver(LoginResult)
            
            scheduler.scheduleAt(100) {
                sut.loginFinished.asObservable().subscribe(results).addDisposableTo(disposeBag)
            }
            
            scheduler.scheduleAt(200) {
                sut.username.value = "johny"
                sut.password.value = "yellowpanties"
                sut.loginTaps.onNext(())
            }
            
            scheduler.start()
            
            XCTAssertEqual(results.events,
                [
                    next(201, LoginResult.Failed(message: "Oops, something went wrong")),
                    completed(201)
                ])
        }
        
        it("should not enable UI elements when invalid credentials are entered") {
            let observer = scheduler.createObserver(Bool)
            
            scheduler.scheduleAt(100) {
                sut.loginEnabled.asObservable().subscribe(observer).addDisposableTo(disposeBag)
            }
            
            scheduler.scheduleAt(200) {
                sut.username.value = "a"
                sut.password.value = "b"
            }
            
            scheduler.start()
            
            let results = observer.events
                .map { event in
                    event.value.element!
                }
            
            expect(results) == [false, false, false]
        }
    }
}
