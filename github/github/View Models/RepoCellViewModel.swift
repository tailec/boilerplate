import Foundation
import RxSwift

struct RepoCellViewModel {
    let fullName: String
    let description: String
    let language: String
    let stars: String
    
    init(repo: Repo) {
        self.fullName = repo.fullName
        self.description = repo.description
        self.language = repo.language ?? ""
        self.stars = "\(repo.stargazers) stars"
    }
}

extension Observable {
    func mapToRepoCellViewModels() -> Observable<[RepoCellViewModel]> {
        return self.map { repos in
            if let repos  = repos as? [Repo] {
                return repos.map { return RepoCellViewModel(repo: $0) }
            } else {
                return []
            }
        }
    }
}