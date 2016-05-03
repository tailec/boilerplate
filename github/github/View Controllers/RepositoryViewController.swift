import UIKit
import RxSwift
import RxCocoa
import SafariServices

class RepositoryViewController: UIViewController {
    
    var viewModel: RepositoryViewModel?
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var forksCountLabel: UILabel!
    @IBOutlet weak private var starsCountLabel: UILabel!
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var readMeButton: UIButton!

    private var datasource =  [RepositorySectionViewModel]()
    private let disposeBag = DisposeBag()
    
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
        
        readMeButton.rx_tap.bindTo(vm.readMeTaps).addDisposableTo(disposeBag)
        
        vm.readMeURLObservable.subscribeNext { [weak self] url in
            let svc = SFSafariViewController(URL: url, entersReaderIfAvailable: true)
            self?.presentViewController(svc, animated: true, completion: nil)
        }
        .addDisposableTo(disposeBag)
        
        vm.dataObservable.driveNext { [weak self] data in
            self?.datasource = data
            self?.tableView.reloadData()
        }
        .addDisposableTo(disposeBag)
    }
}

extension RepositoryViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return datasource[section].header
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return datasource.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource[section].items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RepositoryCell", forIndexPath: indexPath)
        let item = datasource[indexPath.section].items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.subtitle
        return cell
    }
}

// MARK: UI stuff
extension RepositoryViewController {
    private func configureTableView() {
        tableView.tableFooterView = UIView() // Removes separators in empty cells
    }
}
