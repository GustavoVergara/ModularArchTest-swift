//
//  CoreModule.swift
//  ModularArchTest
//
//  Created by Gustavo Vergara Garcia on 01/04/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import MATKit
import XCoordinator

class CoreModule: Module {
    
    var appCoordinator = AppCoordinator()
    
    override func coordinator<R: Route, T: TransitionProtocol>(for route: R, transition: T.Type) -> AnyOptionalCoordinator<R, T>? {
        switch route {
        case let route as AppRoute where self.appCoordinator.hasTransition(for: route):
            return self.appCoordinator.anyOptionalCoordinator as? AnyOptionalCoordinator<R, T>
        default:
            return nil
        }
    }
    
    class AppCoordinator: NavigationCoordinator<AppRoute>, OptionalTransition {
        
        func hasTransition(for route: AppRoute) -> Bool {
            switch route {
            case .externalURL(let url):
                UIApplication.shared.open(url)
                return true
            case .userSearch, .repoDetail, .userProfile:
                return false
            }
        }
        
        override func prepareTransition(for route: AppRoute) -> NavigationTransition {
            switch route {
            case .externalURL(let url):
                UIApplication.shared.open(url)
                return .none()
            case .userSearch, .repoDetail, .userProfile:
                return .none()
            }
        }
        
    }
    
}
