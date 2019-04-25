//
//  OptionalExtensions.swift
//  MATKit
//
//  Created by Gustavo Vergara Garcia on 22/04/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation

public extension Optional {
    
    func fanout<T>(_ element: T?) -> Optional<(Wrapped, T)> {
        if let wrapped = self, let element = element {
            return (wrapped, element)
        } else {
            return nil
        }
    }
    
}
