//
//  GitHubTarget.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 26/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import Moya
import Alamofire

public enum GitHubTarget: TargetType {
    case getRepositories(ownerUsername: String?, type: RepoType, sort: RepoSortType, order: SortOrder)
    case searchIssues(repository: String, state: Issue.State?, sort: SearchIssuesSortType, order: SortOrder)
    
    /// The target's base `URL`.
    public var baseURL: URL {
        return URL(string: "http://GustavoVergara@api.github.com")!
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .getRepositories(let ownerUsername, _, _, _):
            if let ownerUsername = ownerUsername {
                return "/users/\(ownerUsername)/repos"
            } else {
                return "/users/repos"
            }
        case .searchIssues:
            return "/search/issues"
        }
    }
    
    /// The HTTP method used in the request.
    public var method: Moya.Method {
        switch self {
        case .getRepositories:  return .get
        case .searchIssues:     return .get
        }
    }
    
    /// Provides stub data for use in testing.
    public var sampleData: Data {
        switch self {
        case .getRepositories:  return GitHubMocks.getRepositories()
        case .searchIssues:     return GitHubMocks.searchIssues()
        }
    }
    
    /// The type of HTTP task to be performed.
    public var task: Task {
        switch self {
        case let .getRepositories(_, type, sort, order):
            return .requestParameters(
                parameters: [
                    "type": type.rawValue,
                    "sort": sort.rawValue,
                    "direction": order.rawValue
                ],
                encoding: URLEncoding.default
            )
        case let .searchIssues(repository, state, sort, order):
            var queryParameters = ["repo": repository]
            queryParameters["state"] = state?.rawValue
            return .requestParameters(
                parameters: [
                    "q": gitHubQueryString(from: queryParameters),
                    "sort": sort.rawValue,
                    "order": order.rawValue
                ],
                encoding: URLEncoding.default
            )
        }
    }
    
    /// The headers to be used in the request.
    public var headers: [String: String]? {
        switch self {
        case .getRepositories:  return nil
        case .searchIssues:     return nil
        }
    }
    
}

fileprivate func gitHubQueryString(from dictionary: [String: String]) -> String {
    var query = ""
    for (index, element) in dictionary.enumerated() {
        if index > 0 { query += "+" }
        query += "\(element.key):\(element.value)"
    }
    return query
}

// MARK: - Get Repos Parameters

public enum RepoType: String, Codable {
    case all
    case owner
    case member
}

public enum RepoSortType: String, Codable {
    case created
    case updated
    case pushed
    case fullName = "full_name"
}

public enum SortOrder: String {
    case asc
    case desc
}

// MARK: - Search Repos Parameters

public enum ProgrammingLanguage: String {
    case java = "Java"
    case swift = "Swift"
}

public enum SortField: String {
    case stars
    case forks
    case updated
}

// MARK: - Search Issues Parameters

public enum SearchIssuesSortType: String {
    case comments
    case reactions
    case reactionsPlus1 = "reactions-+1"
    case reactionsMinus1 = "reactions--1"
    case reactionsSmile = "reactions-smile"
    case reactionsThinkingFace = "reactions-thinking_face"
    case reactionsHeart = "reactions-heart"
    case reactionsTada = "reactions-tada"
    case interactions
    case created
    case updated
}
