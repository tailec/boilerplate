import UIKit
import Moya
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    var viewModel: LoginViewModel!
    
    @IBOutlet weak private var usernameTextField: UITextField!
    @IBOutlet weak private var passwordTextField: UITextField!
    @IBOutlet weak private var signInButton: UIButton!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindToRx()
        customizeSignInButton()
    }
    
    func bindToRx() {
        _ = usernameTextField.rx_text.bindTo(viewModel.username).addDisposableTo(disposeBag)
        _ = passwordTextField.rx_text.bindTo(viewModel.password).addDisposableTo(disposeBag)
        _ = signInButton.rx_tap.bindTo(viewModel.loginTaps).addDisposableTo(disposeBag)
        
        viewModel.loginEnabled
            .drive(signInButton.rx_enabled)
            .addDisposableTo(disposeBag)
        
        viewModel.loginExecuting
            .driveNext { executing in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = executing
            }
            .addDisposableTo(disposeBag)
        
        viewModel.loginFinished
            .driveNext { [weak self] loginResult in
            switch loginResult {
                case .Failed(let message):
                    let alert = UIAlertController(title: "Oops!", message:message, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
                    self?.presentViewController(alert, animated: true, completion: nil)
                case .OK:
                    self?.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: UI stuff
extension LoginViewController {
    private func customizeSignInButton() {
        signInButton.layer.cornerRadius = 6.0
        signInButton.layer.masksToBounds = true
    }
}
