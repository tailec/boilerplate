import Foundation
import RxSwift
import RxCocoa
import Moya

class DiscoverViewModel {
    
    var triggerRefresh = PublishSubject<Void>()
    var selectedItem = PublishSubject<IndexPath>()
    
    let results: Driver<[RepoCellViewModel]>
    let noResultsFound: Driver<Bool>
    let executing: Driver<Bool>
    let selectedViewModel: Observable<RepositoryViewModel>
    let title = "Trending"
    
    fileprivate let repos: Variable<[Repo]>
    fileprivate let provider: RxMoyaProvider<GitHub>
    
    init(provider: RxMoyaProvider<GitHub>) {
        self.provider = provider
        
//        let activityIndicator = ActivityIndicator()
        self.executing = Variable(false).asDriver().distinctUntilChanged()

        let noResultFoundSubject = Variable(false)
        self.noResultsFound = noResultFoundSubject.asDriver().distinctUntilChanged()
        
        let repos = Variable<[Repo]>([])
        self.repos = repos
        
        results = triggerRefresh.startWith(())
            .flatMapLatest {
                provider.request(.trendingReposSinceLastWeek)
                    .retry(3)
                    .observeOn(MainScheduler.instance)
//                    .trackActivity(activityIndicator)
            }
            .mapJSON()
            .mapToRepos()
            .do(onNext: { (res) in
                repos.value = res
            })
            .mapToRepoCellViewModels()
            .catchErrorJustReturn([])
            .do(onNext: { (viewModels) in
                noResultFoundSubject.value = viewModels.isEmpty
            })
            .asDriver(onErrorJustReturn: [])
        
        selectedViewModel = selectedItem.asObservable()
            .map { indexPath in
                let repo = repos.value[indexPath.row]
                return RepositoryViewModel(provider: provider, repo: repo)
            }
            .shareReplay(1)
    }
}

extension Observable {
    func mapToRepos() -> Observable<[Repo]> {
        return self.map { json in
            let dict = json as? [String: AnyObject]
            if let items = dict?["items"] as? [AnyObject] {
                return Repo.fromJSONArray(items)
            } else {
                return []
            }
        }
    }
}
