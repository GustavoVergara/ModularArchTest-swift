//
//  DictionaryLiteral+Optional.swift
//  MATKit
//
//  Created by Gustavo Vergara Garcia on 22/04/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation

extension Array: ExpressibleByDictionaryLiteral where Element == (String?, Any?) {
    
    public init(dictionaryLiteral elements: (String?, Any?)...) {
        self = elements
    }
    
}

public extension Dictionary {
    
    init(_ elements: [(Key?, Value?)]) {
        let filteredElements = elements.compactMap({ $0.fanout($1) })
        self = [Key: Value](uniqueKeysWithValues: filteredElements)
    }
    
    static func ignoringNil(_ elements: [(Key?, Value?)]) -> [Key: Value] {
        return [Key: Value](elements)
    }
    
}
