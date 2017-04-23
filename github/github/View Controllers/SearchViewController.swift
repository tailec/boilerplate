import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {
    
    var viewModel: SearchViewModel?
    
    @IBOutlet weak fileprivate var searchTextField: UITextField!
    @IBOutlet weak fileprivate var tableView: UITableView!
    @IBOutlet weak fileprivate var exploreNewReposView: UIView!
    @IBOutlet weak fileprivate var nothingFoundView: UIView!

    fileprivate var dataSource = [RepoCellViewModel]()
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        bindToRx()
    }
    
    fileprivate func bindToRx() {
        guard let vm = viewModel else {
            return
        }
        
        title = vm.title
        tabBarItem.title = vm.title

        searchTextField.rx.text.orEmpty
            .bind(to: vm.searchText)
            .addDisposableTo(disposeBag)
        
        tableView.rx.itemSelected
            .bind(to: vm.selectedItem)
            .addDisposableTo(disposeBag)
        
        vm.results.drive(onNext: { [weak self] result in
            self?.removeAnyViewsAboveTableView()
            switch result {
            case .query(let cellViewModels):
                self?.dataSource = cellViewModels
                self?.tableView.reloadData()
            case .empty:
                self?.layoutExploreNewReposView()
            case .queryNothingFound:
                self?.layoutNothingFoundView()
            }

        }).addDisposableTo(disposeBag)

        vm.executing
            .drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
            .addDisposableTo(disposeBag)
        
        vm.selectedViewModel.subscribe(onNext: { [weak self] viewModel in
            let repositoryViewController = UIStoryboard.main.repositoryViewController
            repositoryViewController.viewModel = viewModel
            self?.show(repositoryViewController, sender: nil)
        }).addDisposableTo(disposeBag)
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RepoCell.self), for: indexPath) as! RepoCell
            let rowViewModel = dataSource[indexPath.row]
            cell.configure(rowViewModel.fullName, description: rowViewModel.description, language: rowViewModel.language, stars: rowViewModel.stars)
            return cell
    }
}

// MARK: UI stuff
extension SearchViewController {
    fileprivate func configureTableView() {
        tableView.register(UINib(nibName: String(describing: RepoCell.self), bundle: nil), forCellReuseIdentifier: String(describing: RepoCell.self))
        tableView.tableFooterView = UIView() // Removes separators in empty cells
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    fileprivate func removeAnyViewsAboveTableView() {
        nothingFoundView.removeFromSuperview()
        exploreNewReposView.removeFromSuperview()
    }
    
    fileprivate func layoutNothingFoundView() {
        view.addSubview(nothingFoundView)
        
        let views = [
            "searchTextField" : searchTextField,
            "nothingFoundView" : nothingFoundView
        ]
        nothingFoundView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[nothingFoundView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[searchTextField][nothingFoundView]|", options: [], metrics: nil, views: views))
    }
    
    fileprivate func layoutExploreNewReposView() {
        view.addSubview(exploreNewReposView)
        
        let views = [
            "searchTextField" : searchTextField,
            "exploreNewReposView" : exploreNewReposView
        ]
        exploreNewReposView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[exploreNewReposView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[searchTextField][exploreNewReposView]|", options: [], metrics: nil, views: views))
    }
}
