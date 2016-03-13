import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {
    
    var viewModel: SearchViewModel?
    
    @IBOutlet weak private var searchTextField: UITextField!
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var exploreNewReposView: UIView!
    @IBOutlet weak private var nothingFoundView: UIView!

    private var dataSource = [RepoCellViewModel]()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        bindToRx()
    }
    
    private func bindToRx() {
        guard let vm = viewModel else {
            return
        }
        
        title = vm.title
        tabBarItem.title = vm.title

        searchTextField.rx_text
            .bindTo(vm.searchText)
            .addDisposableTo(disposeBag)
        
        tableView.rx_itemSelected
            .bindTo(vm.selectedItem)
            .addDisposableTo(disposeBag)
        
        vm.results
            .driveNext { [weak self] result in
                self?.removeAnyViewsAboveTableView()
                switch result {
                    case .Query(let cellViewModels):
                        self?.dataSource = cellViewModels
                        self?.tableView.reloadData()
                    case .Empty:
                        self?.layoutExploreNewReposView()
                    case .QueryNothingFound:
                        self?.layoutNothingFoundView()
                }
            }
            .addDisposableTo(disposeBag)

        vm.executing
            .drive(UIApplication.sharedApplication().rx_networkActivityIndicatorVisible)
            .addDisposableTo(disposeBag)
        
        vm.selectedViewModel
            .subscribeNext { [weak self] viewModel in
                let repositoryViewController = UIStoryboard.main.repositoryViewController
                repositoryViewController.viewModel = viewModel
                self?.showViewController(repositoryViewController, sender: nil)
            }
            .addDisposableTo(disposeBag)
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier(String(RepoCell), forIndexPath: indexPath) as! RepoCell
            let rowViewModel = dataSource[indexPath.row]
            cell.configure(rowViewModel.fullName, description: rowViewModel.description, language: rowViewModel.language, stars: rowViewModel.stars)
            return cell
    }
}

// MARK: UI stuff
extension SearchViewController {
    private func configureTableView() {
        tableView.registerNib(UINib(nibName: String(RepoCell), bundle: nil), forCellReuseIdentifier: String(RepoCell))
        tableView.tableFooterView = UIView() // Removes separators in empty cells
        tableView.estimatedRowHeight = 100.0;
        tableView.rowHeight = UITableViewAutomaticDimension;
    }
    
    private func removeAnyViewsAboveTableView() {
        nothingFoundView.removeFromSuperview()
        exploreNewReposView.removeFromSuperview()
    }
    
    private func layoutNothingFoundView() {
        view.addSubview(nothingFoundView)
        
        let views = [
            "searchTextField" : searchTextField,
            "nothingFoundView" : nothingFoundView
        ]
        nothingFoundView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[nothingFoundView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[searchTextField][nothingFoundView]|", options: [], metrics: nil, views: views))
    }
    
    private func layoutExploreNewReposView() {
        view.addSubview(exploreNewReposView)
        
        let views = [
            "searchTextField" : searchTextField,
            "exploreNewReposView" : exploreNewReposView
        ]
        exploreNewReposView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[exploreNewReposView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[searchTextField][exploreNewReposView]|", options: [], metrics: nil, views: views))
    }
}
