//
//  ActionExtensions.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 25/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import Action

extension ActionError {
    var underlying: Error {
        switch self {
        case .notEnabled:
            return self
        case .underlyingError(let error):
            return error
        }
    }
}
