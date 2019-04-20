//
//  DefaultCoordinator.swift
//  MATUI
//
//  Created by Gustavo Vergara Garcia on 30/03/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import MATKit
import XCoordinator

public class DefaultCoordinator: NavigationCoordinator<AppRoute> {
    
    let modules: [Module]
    
    public init(modules: [Module]) {
        self.modules = modules
        super.init(initialRoute: .userSearch)
    }
    
    func destination(for route: AppRoute) -> Module.Destination? {
        return self.modules.firstDestination(for: route, router: self.anyRouter)
    }
    
    private func prepareTransition(for destination: Module.Destination) -> NavigationTransition {
        switch destination {
        case .presentable(let presentable):
            return .push(presentable)
        case .action(let action):
            action()
            return .none()
        }
    }
    
    public override func prepareTransition(for route: AppRoute) -> NavigationTransition {
        guard let destination = self.destination(for: route) else {
            assertionFailure("Destination for route \"\(route)\" not found")
            return .none()
        }
        
        switch route {
        case .userSearch:
            if let rootViewController = self.rootViewController.viewControllers.first,
                type(of: rootViewController) == destination.presentable.map({ type(of: $0) }) {
                return .popToRoot()
            } else {
                return self.prepareTransition(for: destination)
            }

        case .repoDetail, .userProfile, .externalURL:
            return self.prepareTransition(for: destination)
        }
    }
    
}
