import Foundation
import RxSwift
import RxCocoa
import Moya

class LoginViewModel {
    // Input
    var username = Variable("")
    var password = Variable("")
    var loginTaps = PublishSubject<Void>()
    
    // Output
    let loginEnabled: Driver<Bool>
    let loginFinished: Driver<LoginResult>
    let loginExecuting: Driver<Bool>
    
    // Private
    fileprivate let provider: RxMoyaProvider<GitHub>
    
    init(provider: RxMoyaProvider<GitHub>) {
        self.provider = provider
        
//        let activityIndicator = ActivityIndicator()
        loginExecuting = Variable(false).asDriver().distinctUntilChanged()

        let usernameObservable = username.asObservable()
        let passwordObservable = password.asObservable()
        
        loginEnabled = Observable.combineLatest(usernameObservable, passwordObservable)
            { $0.characters.count > 0 && $1.characters.count > 6 }
            .asDriver(onErrorJustReturn: false)
        
        let usernameAndPassword = Observable.combineLatest(usernameObservable, passwordObservable)
            { ($0, $1) }
        
        loginFinished = loginTaps
            .asObservable()
            .withLatestFrom(usernameAndPassword)
            .flatMapLatest { (username, password) in
                provider.request(GitHub.token(username: username, password: password))
                    .retry(3)
//                    .trackActivity(activityIndicator)
                    .observeOn(MainScheduler.instance)
            }
            .checkIfRateLimitExceeded()
            .mapJSON()
            .do(onNext: { json in
                var appToken = Token()
//                appToken.token = json["token"] as? String
            })
            .map { json in
//                if let message = json["message"] as? String {
//                    return LoginResult.failed(message: message)
//                } else {
//                    return LoginResult.ok
//                }
                return LoginResult.ok
            }
            .asDriver(onErrorJustReturn: LoginResult.failed(message: "Oops, something went wrong")).debug()
    }
}
