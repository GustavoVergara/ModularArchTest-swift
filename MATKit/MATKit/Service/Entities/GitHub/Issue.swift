//
//  Issue.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 26/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation

public struct Issue: Codable {
    public var id: Int
    public var url: URL?
    public var repositoryURL: URL?
    public var labelsURL: URL?
    public var commentsURL: URL?
    public var eventsURL: URL?
    public var htmlURL: URL?
    public var number: Int?
    public var state: State?
    public var title: String?
    public var body: String?
    public var user: User?
    public var assignee: User?
    public var milestone: Milestone?
    public var locked: Bool?
    public var comments: Int?
    public var closedAt: Date?
    public var createdAt: Date?
    public var updatedAt: Date?
    public var closedBy: User?
    
    // MARK: -
    public enum State: String, Codable {
        case open = "open"
        case closed = "closed"
    }
    
}
