import Foundation
import RxSwift
import RxCocoa
import Moya
import SwiftyJSON

class RepositoryViewModel {
    // Input
    var readMeTaps = PublishSubject<Void>()
    
    // Output
    var fullName: String { return repo.fullName }
    var description: String { return repo.description }
    var forksCounts: String { return String(repo.forks) }
    var starsCount: String { return String(repo.stargazers) }
    
    let readMeURLObservable: Observable<URL>
    let dataObservable: Driver<[RepositorySectionViewModel]> // naming is hard
    
    fileprivate let provider: RxMoyaProvider<GitHub>
    fileprivate let repo: Repo
    
    init(provider: RxMoyaProvider<GitHub>, repo: Repo) {
        self.provider = provider
        self.repo = repo
        
        readMeURLObservable = readMeTaps
            .asObservable()
            .flatMap { _ in
                GitHubProvider.request(GitHub.repoReadMe(owner: repo.owner.name, repoName: repo.fullName))
                    .retry(3)
                    .observeOn(MainScheduler.instance)
            }
            .mapJSON()
            .map {
                JSON($0)
            }
            .map { json in
                URL(string: json["html_url"].stringValue)!
            }

            .shareReplay(1)
        
        let lastThreePullsObservable =  provider.request(GitHub.pulls(onwer: repo.owner.name, repo: repo.fullName))
            .mapToModels(PullRequest.self)
            .asDriver(onErrorJustReturn: [])
            .map { (models: [PullRequest]) -> RepositorySectionViewModel in
                let items = models.prefix(upTo: 3).map {
                    RepositoryCellViewModel(title: $0.title, subtitle: "by " + $0.author)
                }
                return RepositorySectionViewModel(header: "Last three pull requests", items: items)
            }
        
        let lastThreeIssuesObservable =  provider.request(GitHub.issues(onwer: repo.owner.name, repo: repo.fullName))
            .mapToModels(Issue.self)
            .asDriver(onErrorJustReturn: [])
            .map { (models: [Issue]) -> RepositorySectionViewModel in
                let items = models.prefix(upTo: 3).map {
                    RepositoryCellViewModel(title: $0.title, subtitle: "by " + $0.author)
                }
                return RepositorySectionViewModel(header: "Last three issues", items: items)
            }
        
        let lastThreeCommitsObservable = provider.request(GitHub.commits(onwer: repo.owner.name, repo: repo.fullName))
            .mapToModels(Commit.self)
            .asDriver(onErrorJustReturn: [])
            .map { (models: [Commit]) -> RepositorySectionViewModel in
                let items = models.prefix(upTo: 3).map {
                    RepositoryCellViewModel(title: $0.message, subtitle: "by " + $0.author)
                }
                return RepositorySectionViewModel(header: "Last three commits", items: items)
            }
        
        dataObservable = Driver.zip(lastThreePullsObservable, lastThreeIssuesObservable, lastThreeCommitsObservable) {
                [$0, $1, $2].filter { !$0.items.isEmpty } // don't include empty sections in datasource
            }
    }
}

struct RepositorySectionViewModel {
    let header: String
    let items: [RepositoryCellViewModel]
}

struct RepositoryCellViewModel {
    let title: String
    let subtitle: String
}
