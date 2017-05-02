import UIKit
import Moya
import RxSwift
import RxCocoa

class DiscoverViewController: UIViewController {
    
    var viewModel: DiscoverViewModel?
    
    @IBOutlet weak fileprivate var tableView: UITableView!
    @IBOutlet weak fileprivate var noResultsView: UIView!
    fileprivate let refreshControl = UIRefreshControl()
    
    fileprivate let disposeBag = DisposeBag()
    
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
        
        tableView.rx.itemSelected
            .bind(to: vm.selectedItem)
            .addDisposableTo(disposeBag)
        
//        vm.results.drive(tableView.rx.itemsWithCellFactory) {
//            (tv: UITableView, index, rowViewModel: RepoCellViewModel) in
//                let indexPath = NSIndexPath(forItem: index, inSection: 0)
//                let cell = tv.dequeueReusableCellWithIdentifier(String(RepoCell), forIndexPath: indexPath) as! RepoCell
//                cell.configure(rowViewModel.fullName, description: rowViewModel.description, language: rowViewModel.language, stars: rowViewModel.stars)
//                return cell
//            }
//            .addDisposableTo(disposeBag)

        vm.results.drive(onNext: { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }).addDisposableTo(disposeBag)
        
        vm.executing.drive(onNext: { executing in
            UIApplication.shared.isNetworkActivityIndicatorVisible = executing
        }).addDisposableTo(disposeBag)
        
        vm.noResultsFound
            .map { !$0 }
            .drive(noResultsView.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        vm.selectedViewModel.subscribe(onNext: { [weak self] repoViewModel in
            let repositoryViewController = UIStoryboard.main.repositoryViewController
            repositoryViewController.viewModel = repoViewModel
            self?.show(repositoryViewController, sender: nil)
        }).addDisposableTo(disposeBag)
        
        let tapGestureRecognizer = UITapGestureRecognizer()
        noResultsView.addGestureRecognizer(tapGestureRecognizer)
        
        _ = Observable.of(refreshControl.rx_animating.asObservable(), tapGestureRecognizer.rx.event.map { _ in () })
            .merge()
            .bind(to: vm.triggerRefresh)
            .addDisposableTo(disposeBag)
        
    }
    
    fileprivate func configureTableView() {
        tableView.register(UINib(nibName: String(describing: RepoCell.self), bundle: nil), forCellReuseIdentifier: String(describing: RepoCell.self))
        tableView.tableFooterView = UIView() // Removes separators in empty cells
        tableView.estimatedRowHeight = 100.0;
        tableView.rowHeight = UITableViewAutomaticDimension;
    }
    
    fileprivate func configureRefreshControl() {
        refreshControl.backgroundColor = UIColor.clear
        refreshControl.tintColor = UIColor.lightGray
        tableView.addSubview(refreshControl)
    }
}
