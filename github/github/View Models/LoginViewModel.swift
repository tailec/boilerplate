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
    private let provider: RxMoyaProvider<GitHub>
    
    init(provider: RxMoyaProvider<GitHub>) {
        self.provider = provider
        
        let activityIndicator = ActivityIndicator()
        loginExecuting = activityIndicator
            .asDriver()
        
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
                provider.request(GitHub.Token(username: username, password: password))
                    .retry(3)
                    .trackActivity(activityIndicator)
                    .observeOn(MainScheduler.instance)
            }
            .checkIfRateLimitExceeded()
            .mapJSON()
            .doOn(onNext: { json in
                var appToken = Token()
                appToken.token = json["token"] as? String
            })
            .map { json in
                if let message = json["message"] as? String {
                    return LoginResult.Failed(message: message)
                } else {
                    return LoginResult.OK
                }
            }
            .asDriver(onErrorJustReturn: LoginResult.Failed(message: "Oops, something went wrong")).debug()
    }
}
