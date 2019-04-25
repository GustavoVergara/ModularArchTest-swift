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
    
    let githubJSONDecoder = JSONDecoder(dateDecodingStrategy: .iso8601(formatOptions: .withInternetDateTime))
    
    let gitHubProvider: MoyaProvider<GitHubTarget>
    
    public init(
        gitHubProvider: MoyaProvider<GitHubTarget> = MoyaProvider<GitHubTarget>(plugins: [NetworkActivityIndicatorPlugin.default, CacheControlPlugin.default])
    ) {
        self.gitHubProvider = gitHubProvider
    }

    public func getRepositories(ownerUsername: String?, type: RepoType = .all, sort: RepoSortType = .updated, order: SortOrder = .desc) -> Single<[Repository]> {
        return self.gitHubProvider.rx.request(.getRepositories(ownerUsername: ownerUsername, type: type, sort: sort, order: order))
            .filterSuccessfulStatusAndRedirectCodes()
            .map([Repository].self, using: self.githubJSONDecoder)
    }
    
    public func searchIssues(repositoryFullName: String, state: Issue.State? = nil, sort: SearchIssuesSortType = .updated, order: SortOrder = .desc) -> Single<SearchResult<Issue>> {
        return self.gitHubProvider.rx.request(.searchIssues(repository: repositoryFullName, state: state, sort: sort, order: order))
            .filterSuccessfulStatusAndRedirectCodes()
            .map(SearchResult<Issue>.self, using: self.githubJSONDecoder)
    }
    
    public func searchUsers(login: String, page: Int = 1, sort: SearchUsersSortType? = nil, order: SortOrder = .desc) -> Single<SearchResult<User>> {
        return self.gitHubProvider.rx.request(.searchUsers(login: login, page: page, sort: sort, order: order))
            .filterSuccessfulStatusAndRedirectCodes()
            .map(SearchResult<User>.self, using: self.githubJSONDecoder)
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
