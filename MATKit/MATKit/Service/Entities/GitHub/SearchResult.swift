//
//  SearchResult.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 26/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation

public struct SearchResult<Item: Codable>: Codable {
    public var totalCount: Int
    public var isIncomplete: Bool
    public var items: [Item]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case isIncomplete = "incomplete_results"
        case items
    }
}
