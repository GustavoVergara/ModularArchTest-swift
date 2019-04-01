//
//  PullRequest.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 26/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation

public struct PullRequest: Codable {
    
    public var id: Int
    public var url: URL?

    public var htmlURL: URL?
    public var diffURL: URL?
    public var patchURL: URL?
    public var issueURL: URL?
    public var commitsURL: URL?
    public var reviewCommentsURL: URL?
    public var commentsURL: URL?
    public var statusesURL: URL?

    public var number: Int?
    public var state: State?
    public var title: String?
    public var body: String?

    public var assignee: User?
    public var milestone: Milestone?
    
    public var locked: Bool?
    public var createdAt: Date?
    public var updatedAt: Date?
    public var closedAt: Date?
    public var mergedAt: Date?

    public var user: User?
    
    // MARK: -
    public enum State: String, Codable {
        case open = "open"
        case closed = "closed"
    }
    
    // MARK: -
    enum CodingKeys: String, CodingKey {
        case id
        case url
        
        case htmlURL = "html_url"
        case diffURL = "diff_url"
        case patchURL = "patch_url"
        case issueURL = "issue_url"
        case commitsURL = "commits_url"
        case reviewCommentsURL = "review_comments_url"
//        case reviewCommentURL = "review_comment_url"
        case commentsURL = "comments_url"
        case statusesURL = "statuses_url"
        
        case number
        case state
        case title
        case body
        
        case assignee
        case milestone
        
        case locked
        case createdAt = "closed_at"
        case updatedAt = "created_at"
        case closedAt = "updated_at"
        case mergedAt = "merged_at"
        
        case user
    }
    
}
