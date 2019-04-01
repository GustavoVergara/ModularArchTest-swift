//
//  Repository.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 26/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation

public struct Repository: Codable, Hashable {
    public typealias ID = Int
    
    public var id: ID
    public var owner: User
    public var name: String
    public var fullName: String
    public var isPrivate: Bool
    public var description: String?
    public var isFork: Bool?
    public var gitURL: URL?
    public var sshURL: URL?
    public var cloneURL: URL?
    public var htmlURL: URL?
    public var size: Int
    public var createdAt: Date?
    public var updatedAt: Date?
    public var pushedAt: Date?
    public var watchersCount: Int?
    public var forksCount: Int?
    public var stargazersCount: Int?
    public var language: String?
    public var openIssuesCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case name
        case fullName = "full_name"
        case isPrivate = "private"
        case description
        case isFork = "fork"
        case gitURL = "git_url"
        case sshURL = "ssh_url"
        case cloneURL = "clone_url"
        case htmlURL = "html_url"
        case size
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case pushedAt = "pushed_at"
        case watchersCount = "watchers_count"
        case forksCount = "forks_count"
        case stargazersCount = "stargazers_count"
        case language
        case openIssuesCount = "open_issues_count"
    }
    
}
