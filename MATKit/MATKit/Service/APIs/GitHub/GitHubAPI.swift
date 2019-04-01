//
//  GitHubAPI.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 26/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import Moya
import RxMoya
import RxSwift
import Alamofire

public struct GitHubAPI {
    
    let gitHubProvider: MoyaProvider<GitHubTarget>
    
    public init(
        gitHubProvider: MoyaProvider<GitHubTarget> = MoyaProvider<GitHubTarget>(plugins: [NetworkActivityIndicatorPlugin.default, CacheControlPlugin.default])
    ) {
        self.gitHubProvider = gitHubProvider
    }

    public func getRepositories(ownerUsername: String?, type: RepoType = .all, sort: RepoSortType = .updated, order: SortOrder = .desc) -> Single<[Repository]> {
        return self.gitHubProvider.rx.request(.getRepositories(ownerUsername: ownerUsername, type: type, sort: sort, order: order))
            .catchError({ (error) -> Single<Response> in
                return Single.error(error)
            })
            .filterSuccessfulStatusAndRedirectCodes()
            .map([Repository].self, using: JSONDecoder(dateDecodingStrategy: .iso8601(formatOptions: .withInternetDateTime)))
    }
    
    public func searchIssues(repositoryFullName: String, state: Issue.State? = nil, sort: SearchIssuesSortType = .updated, order: SortOrder = .desc) -> Single<SearchResult<Issue>> {
        return self.gitHubProvider.rx.request(.searchIssues(repository: repositoryFullName, state: state, sort: sort, order: order))
            .filterSuccessfulStatusAndRedirectCodes()
            .map(SearchResult<Issue>.self, using: JSONDecoder(dateDecodingStrategy: .iso8601(formatOptions: .withInternetDateTime)))
    }
    
}

public extension GitHubAPI {
    
    func getRepositoriesFromCurrentUser(type: RepoType = .all, sort: RepoSortType = .updated, order: SortOrder = .desc) -> Single<[Repository]> {
        return self.getRepositories(ownerUsername: nil, type: type, sort: sort, order: order)
    }
    
    func searchIssues(repository: Repository, state: Issue.State?, sort: SearchIssuesSortType, order: SortOrder) -> Single<SearchResult<Issue>> {
        return self.searchIssues(repositoryFullName: repository.fullName, state: state, sort: sort, order: order)
    }
    
    func searchIssues(repository: Repository) -> Single<SearchResult<Issue>> {
        return self.searchIssues(repository: repository, state: nil, sort: .updated, order: .desc)
    }
    
}