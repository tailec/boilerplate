import UIKit
import Moya
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    var viewModel: LoginViewModel!
    
    @IBOutlet weak fileprivate var usernameTextField: UITextField!
    @IBOutlet weak fileprivate var passwordTextField: UITextField!
    @IBOutlet weak fileprivate var signInButton: UIButton!
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindToRx()
        customizeSignInButton()
    }
    
    func bindToRx() {
        usernameTextField.rx.text.orEmpty.bind(to: viewModel.username).addDisposableTo(disposeBag)
        passwordTextField.rx.text.orEmpty.bind(to: viewModel.password).addDisposableTo(disposeBag)
        signInButton.rx.tap.bind(to: viewModel.loginTaps).addDisposableTo(disposeBag)
        
        viewModel.loginEnabled
            .drive(signInButton.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        viewModel.loginExecuting.drive(onNext: { (executing) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = executing
        }).addDisposableTo(disposeBag)
        
        viewModel.loginFinished.drive(onNext: { [weak self] loginResult in
            switch loginResult {
            case .failed(let message):
                let alert = UIAlertController(title: "Oops!", message:message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
                self?.present(alert, animated: true, completion: nil)
            case .ok:
                self?.dismiss(animated: true, completion: nil)
            }
        }).addDisposableTo(disposeBag)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: UI stuff
extension LoginViewController {
    fileprivate func customizeSignInButton() {
        signInButton.layer.cornerRadius = 6.0
        signInButton.layer.masksToBounds = true
    }
}
