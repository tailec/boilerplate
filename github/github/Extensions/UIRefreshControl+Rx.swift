import Foundation
import RxSwift
import RxCocoa

extension UIRefreshControl {
    public var rx_animating: ControlEvent<Void> {
        return rx.controlEvent(.valueChanged)
    }
}
