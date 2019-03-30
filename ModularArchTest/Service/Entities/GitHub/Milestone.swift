//
//  Milestone.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 26/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation

struct Milestone: Codable {
    var url: URL?
    var htmlURL: URL?
    var labelsURL: URL?
    var id: Int
    var number: Int?
    var state: State?
    var title: String?
    var milestoneDescription: String?
    var creator: User?
    var openIssues: Int?
    var closedIssues: Int?
    var createdAt: Date?
    var updatedAt: Date?
    var closedAt: Date?
    var dueOn: Date?

    enum State: String, Codable {
        case open
        case closed
    }
}
