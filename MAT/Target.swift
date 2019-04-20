//
//  Target.swift
//  MAT
//
//  Created by Gustavo Vergara Garcia on 08/04/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import XCoordinator
import MATKit

protocol Target {
    var modules: [Module] { get }
    var mainCoordinator: NavigationCoordinator<AppRoute> { get }

    init()
}

class TargetContainer {
    private init() {}
    
    private static var _targetType: Target.Type?
    static var target: Target = {
        precondition(TargetContainer._targetType != nil, "A Target must be set before initializing the application")
        return TargetContainer._targetType!.init()
    }()
    
    static func keep(_ targetType: Target.Type) {
        self._targetType = targetType
    }
    
}
