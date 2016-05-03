import Foundation
import RxSwift
import RxCocoa
import Moya

enum SearchViewModelResult {
    case Query([RepoCellViewModel])
    case QueryNothingFound
    case Empty
}

class SearchViewModel {

    // Input
    var searchText = Variable("")
    var selectedItem = PublishSubject<NSIndexPath>()
    
    // Output
    let results: Driver<SearchViewModelResult>
    let executing: Driver<Bool>
    let selectedViewModel: Observable<RepositoryViewModel>
    let title = "Search"
    
    private let repoModels: Variable<[Repo]>
    private let provider: RxMoyaProvider<GitHub>
    
    init(provider: RxMoyaProvider<GitHub>) {
        self.provider = provider
        
        let activityIndicator = ActivityIndicator()
        self.executing = activityIndicator.asDriver().distinctUntilChanged()
        
        let repoModels = Variable<[Repo]>([])
        self.repoModels = repoModels
        
        let searchTextObservable = searchText.asObservable()
        
        let queryResultsObservable = searchTextObservable
            .throttle(0.3, scheduler: MainScheduler.instance)
            .filter { $0.characters.count > 0 }
            .flatMapLatest { query in
                provider.request(GitHub.RepoSearch(query: query))
                    .retry(3)
                    .trackActivity(activityIndicator)
                    .observeOn(MainScheduler.instance)
            }
            .mapToModels(Repo.self, arrayRootKey: "items")
            .doOnNext { models in
                repoModels.value = models
            }
            .mapToRepoCellViewModels()
            .map { viewModels -> SearchViewModelResult in
                viewModels.isEmpty ? .QueryNothingFound : .Query(viewModels)
            }
            .asDriver(onErrorJustReturn: .QueryNothingFound)
        
         let noResultsObservable = searchTextObservable
            .filter { $0.characters.count == 0 }
            .map { _ -> SearchViewModelResult in
                .Empty
            }
            .asDriver(onErrorJustReturn: .Empty)
        
        results = Driver.of(queryResultsObservable, noResultsObservable).merge()
        
        selectedViewModel = selectedItem
            .withLatestFrom(repoModels.asObservable()) { indexPath, models in
                models[indexPath.row]
            }
            .map { model in
                RepositoryViewModel(provider: provider, repo: model)
            }
            .shareReplay(1)
    }
}
