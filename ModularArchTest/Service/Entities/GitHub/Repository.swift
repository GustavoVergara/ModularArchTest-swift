//
//  Repository.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 26/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation

struct Repository: Codable, Hashable {
    typealias ID = Int
    
    let id: ID
    let owner: User
    var name: String
    var fullName: String
    var isPrivate: Bool
    var description: String?
    var isFork: Bool?
    var gitURL: URL?
    var sshURL: URL?
    var cloneURL: URL?
    var htmlURL: URL?
    var size: Int
    var createdAt: Date?
    var updatedAt: Date?
    var pushedAt: Date?
    var watchersCount: Int?
    var forksCount: Int?
    var stargazersCount: Int?
    var language: String?
    var openIssuesCount: Int?
    
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
