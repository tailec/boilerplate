import UIKit
import RxSwift
import RxCocoa
import SafariServices

class RepositoryViewController: UIViewController {
    
    var viewModel: RepositoryViewModel?
    
    @IBOutlet weak fileprivate var titleLabel: UILabel!
    @IBOutlet weak fileprivate var descriptionLabel: UILabel!
    @IBOutlet weak fileprivate var forksCountLabel: UILabel!
    @IBOutlet weak fileprivate var starsCountLabel: UILabel!
    @IBOutlet weak fileprivate var tableView: UITableView!
    @IBOutlet weak fileprivate var readMeButton: UIButton!

    fileprivate var datasource =  [RepositorySectionViewModel]()
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindToRx()
        configureTableView()
    }
    
    func bindToRx() {
        guard let vm = viewModel else { return }
        
        title = vm.fullName
        titleLabel.text = vm.fullName
        descriptionLabel.text = vm.description
        forksCountLabel.text = vm.forksCounts
        starsCountLabel.text = vm.starsCount
        
        readMeButton.rx.tap.bind(to: vm.readMeTaps).addDisposableTo(disposeBag)
        
        vm.readMeURLObservable.subscribe(onNext: { [weak self] url in
            let svc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            self?.present(svc, animated: true, completion: nil)
        })
        .addDisposableTo(disposeBag)

        vm.dataObservable.drive(onNext: { [weak self] data in
            self?.datasource = data
            self?.tableView.reloadData()
        }).addDisposableTo(disposeBag)
    }
}

extension RepositoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return datasource[section].header
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryCell", for: indexPath)
        let item = datasource[indexPath.section].items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.subtitle
        return cell
    }
}

// MARK: UI stuff
extension RepositoryViewController {
    fileprivate func configureTableView() {
        tableView.tableFooterView = UIView() // Removes separators in empty cells
    }
}
