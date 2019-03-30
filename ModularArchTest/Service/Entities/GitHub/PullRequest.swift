//
//  PullRequest.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 26/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation

struct PullRequest: Codable {
    
    var id: Int
    var url: URL?
    
    var htmlURL: URL?
    var diffURL: URL?
    var patchURL: URL?
    var issueURL: URL?
    var commitsURL: URL?
    var reviewCommentsURL: URL?
//    var reviewCommentURL: URL?
    var commentsURL: URL?
    var statusesURL: URL?
    
    var number: Int?
    var state: State?
    var title: String?
    var body: String?
    
    var assignee: User?
    var milestone: Milestone?
    
    var locked: Bool?
    var createdAt: Date?
    var updatedAt: Date?
    var closedAt: Date?
    var mergedAt: Date?
    
    var user: User?
    
    // MARK: -
    enum State: String, Codable {
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
