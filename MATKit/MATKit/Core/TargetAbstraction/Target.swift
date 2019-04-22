//
//  Target.swift
//  MAT
//
//  Created by Gustavo Vergara Garcia on 08/04/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import XCoordinator

public protocol Target {
    var modules: [Module] { get }
    var mainCoordinator: NavigationCoordinator<AppRoute> { get }

    init()
}

public extension Target {
    
    func destination<R: Route>(for route: R, router: AnyRouter<R>) -> Module.Destination? {
        return self.modules.firstDestination(for: route, router: router)
    }
    
}

public class TargetContainer {
    private init() {}
    
    private static var _targetType: Target.Type?
    public static var target: Target = {
        precondition(TargetContainer._targetType != nil, "A Target must be set before initializing the application")
        return TargetContainer._targetType!.init()
    }()
    
    public static func keep(_ targetType: Target.Type) {
        self._targetType = targetType
    }
    
}
