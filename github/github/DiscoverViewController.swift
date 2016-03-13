import UIKit
import Moya
import RxSwift
import RxCocoa

class DiscoverViewController: UIViewController {
    
    var viewModel: DiscoverViewModel?
    
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var noResultsView: UIView!
    private let refreshControl = UIRefreshControl()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureRefreshControl()
        bindToRx()
    }
    
    func bindToRx() {
        guard let vm = viewModel else { return }
        
        title = vm.title
        tabBarItem.title = vm.title
        
        tableView.rx_itemSelected
            .bindTo(vm.selectedItem)
            .addDisposableTo(disposeBag)
        
        vm.results.drive(tableView.rx_itemsWithCellFactory) {
            (tv: UITableView, index, rowViewModel: RepoCellViewModel) in
                let indexPath = NSIndexPath(forItem: index, inSection: 0)
                let cell = tv.dequeueReusableCellWithIdentifier(String(RepoCell), forIndexPath: indexPath) as! RepoCell
                cell.configure(rowViewModel.fullName, description: rowViewModel.description, language: rowViewModel.language, stars: rowViewModel.stars)
                return cell
            }
            .addDisposableTo(disposeBag)
        
        vm.results
            .driveNext { [weak self] _ in
                self?.refreshControl.endRefreshing()
            }
            .addDisposableTo(disposeBag)
        
        vm.executing
            .driveNext { executing in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = executing
            }
            .addDisposableTo(disposeBag)
        
        vm.noResultsFound
            .map { !$0 }
            .drive(noResultsView.rx_hidden)
            .addDisposableTo(disposeBag)
        
        vm.selectedViewModel
            .subscribeNext { [weak self] repoViewModel in
                let repositoryViewController = UIStoryboard.main.repositoryViewController
                repositoryViewController.viewModel = repoViewModel
                self?.showViewController(repositoryViewController, sender: nil)
            }
            .addDisposableTo(disposeBag)
        
        let tapGestureRecognizer = UITapGestureRecognizer()
        noResultsView.addGestureRecognizer(tapGestureRecognizer)
        
        _ = Observable.of(refreshControl.rx_animating.asObservable(), tapGestureRecognizer.rx_event.map { _ in () })
            .merge()
            .bindTo(vm.triggerRefresh)
            .addDisposableTo(disposeBag)
        
    }
    
    private func configureTableView() {
        tableView.registerNib(UINib(nibName: String(RepoCell), bundle: nil), forCellReuseIdentifier: String(RepoCell))
        tableView.tableFooterView = UIView() // Removes separators in empty cells
        tableView.estimatedRowHeight = 100.0;
        tableView.rowHeight = UITableViewAutomaticDimension;
    }
    
    private func configureRefreshControl() {
        refreshControl.backgroundColor = UIColor.clearColor()
        refreshControl.tintColor = UIColor.lightGrayColor()
        tableView.addSubview(refreshControl)
    }
}
