import Foundation
import RxSwift
import RxCocoa
import Moya

enum SearchViewModelResult {
    case query([RepoCellViewModel])
    case queryNothingFound
    case empty
}

class SearchViewModel {

    // Input
    var searchText = Variable("")
    var selectedItem = PublishSubject<IndexPath>()
    
    // Output
    let results: Driver<SearchViewModelResult>
    let executing: Driver<Bool>
    let selectedViewModel: Observable<RepositoryViewModel>
    let title = "Search"
    
    fileprivate let repoModels: Variable<[Repo]>
    fileprivate let provider: RxMoyaProvider<GitHub>
    
    init(provider: RxMoyaProvider<GitHub>) {
        self.provider = provider
        
//        let activityIndicator = ActivityIndicator()
        self.executing = Variable(false).asDriver().distinctUntilChanged()

        let repoModels = Variable<[Repo]>([])
        self.repoModels = repoModels
        
        let searchTextObservable = searchText.asObservable()
        
        let queryResultsObservable = searchTextObservable
            .throttle(0.3, scheduler: MainScheduler.instance)
            .filter { $0.characters.count > 0 }
            .flatMapLatest { query in
                provider.request(GitHub.repoSearch(query: query))
                    .retry(3)
//                    .trackActivity(activityIndicator)
                    .observeOn(MainScheduler.instance)
            }
            .mapToModels(Repo.self, arrayRootKey: "items")
            .do(onNext: { models in
                repoModels.value = models
            })
            .mapToRepoCellViewModels()
            .map { viewModels -> SearchViewModelResult in
                viewModels.isEmpty ? .queryNothingFound : .query(viewModels)
            }
            .asDriver(onErrorJustReturn: .queryNothingFound)
        
         let noResultsObservable = searchTextObservable
            .filter { $0.characters.count == 0 }
            .map { _ -> SearchViewModelResult in
                .empty
            }
            .asDriver(onErrorJustReturn: .empty)
        
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
