//
//  AppCoordinator.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 25/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import XCoordinator

public enum AppRoute: Route, Equatable {
    case userSearch
    case userProfile(user: User, repositories: [Repository])
    case repoDetail(Repository)
    case externalURL(URL)
}

open class Module {
    
    public init() {}
    
//    open func router<R: Route>(for route: R) -> AnyRouter<R>? {
//        assertionFailure("Please override the \(#function) method.")
//        return nil
//    }

    open func coordinator<R: Route, T: TransitionProtocol>(for route: R, transition: T.Type) -> AnyOptionalCoordinator<R, T>? {
        assertionFailure("Please override the \(#function) method.")
        return nil
    }
    
}

public extension Collection where Element: Module {
    
//    func firstRouter<R: Route>(for route: R) -> AnyRouter<R>? {
//        for module in self {
//            guard let router = module.router(for: route) else {
//                continue
//            }
//            return router
//        }
//        return nil
//    }
    
    func firstCoordinator<R: Route, T: TransitionProtocol>(for route: R, transition: T.Type) -> AnyOptionalCoordinator<R, T>? {
        for module in self {
            guard let coordinator = module.coordinator(for: route, transition: transition), coordinator.hasTransition(for: route) else {
                continue
            }
            return coordinator
        }
        return nil
    }
    
}
