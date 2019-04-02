//
//  Module.swift
//  MATKit
//
//  Created by Gustavo Vergara Garcia on 01/04/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import XCoordinator

open class Module {
    
    public init() {}
    
    open func destination<R: Route>(for route: R, router: AnyRouter<R>) -> Destination? {
        assertionFailure("Please override the \(#function) method.")
        return nil
    }
    
    public enum Destination {
        case presentable(Presentable)
        case action(() -> Void)
        
        public var presentable: Presentable? {
            switch self {
            case .presentable(let presentable):
                return presentable
            case .action:
                return nil
            }
        }
    }
    
}

public extension Collection where Element: Module {
    
    func firstDestination<R: Route>(for route: R, router: AnyRouter<R>) -> Module.Destination? {
        for module in self {
            if let destination = module.destination(for: route, router: router) {
                return destination
            } else {
                continue
            }
        }
        return nil
    }
    
}
