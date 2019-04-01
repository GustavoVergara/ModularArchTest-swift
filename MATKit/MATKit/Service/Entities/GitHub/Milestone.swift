//
//  Milestone.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 26/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation

public struct Milestone: Codable {
    public var url: URL?
    public var htmlURL: URL?
    public var labelsURL: URL?
    public var id: Int
    public var number: Int?
    public var state: State?
    public var title: String?
    public var milestoneDescription: String?
    public var creator: User?
    public var openIssues: Int?
    public var closedIssues: Int?
    public var createdAt: Date?
    public var updatedAt: Date?
    public var closedAt: Date?
    public var dueOn: Date?

    public enum State: String, Codable {
        case open
        case closed
    }
}
