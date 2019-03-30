//
//  SearchResult.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 26/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation

struct SearchResult<Item: Codable>: Codable {
    var totalCount: Int
    var isIncomplete: Bool
    var items: [Item]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case isIncomplete = "incomplete_results"
        case items
    }
}
