//
//  ActivityIndicator.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 10/18/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

//struct ActivityToken<E> : ObservableConvertibleType, Disposable {
//    fileprivate let _source: Observable<E>
//    fileprivate let _dispose: AnonymousDisposable
//    
//    init(source: Observable<E>, disposeAction: () -> ()) {
//        _source = source
//        _dispose = AnonymousDisposable(disposeAction)
//    }
//    
//    func dispose() {
//        _dispose.dispose()
//    }
//    
//    func asObservable() -> Observable<E> {
//        return _source
//    }
//}

/**
 Enables monitoring of sequence computation.
 If there is at least one sequence computation in progress, `true` will be sent.
 When all activities complete `false` will be sent.
 */
//class ActivityIndicator : SharedSequenceConvertibleType {
//    typealias E = Bool
//    
//    fileprivate let _lock = NSRecursiveLock()
//    fileprivate let _variable = Variable(0)
//    fileprivate let _loading: Driver<Bool>
//    
//    init() {
//        _loading = _variable.asObservable()
//            .map { $0 > 0 }
//            .distinctUntilChanged()
//            .asDriver { (error: Error) -> Driver<Bool> in
//                _ = fatalError("Loader can't fail")
//                return Driver.empty()
//        }
//    }
//    
//    func trackActivity<O: ObservableConvertibleType>(_ source: O) -> Observable<O.E> {
//        return Observable.using({ () -> ActivityToken<O.E> in
//            self.increment()
//            return ActivityToken(source: source.asObservable(), disposeAction: self.decrement)
//            }) { t in
//                return t.asObservable()
//        }
//    }
//    
//    fileprivate func increment() {
//        _lock.lock()
//        _variable.value = _variable.value + 1
//        _lock.unlock()
//    }
//    
//    fileprivate func decrement() {
//        _lock.lock()
//        _variable.value = _variable.value - 1
//        _lock.unlock()
//    }
//    
//    func asDriver() -> Driver<E> {
//        return _loading
//    }
//}
//
//extension ObservableConvertibleType {
//    func trackActivity(_ activityIndicator: ActivityIndicator) -> Observable<E> {
//        return activityIndicator.trackActivity(self)
//    }
//}
