//
//  Coordinator.swift
//  MATUI
//
//  Created by Gustavo Vergara Garcia on 30/03/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import MATKit
import XCoordinator

#if canImport(MATUI)
import MATUI
#endif

public class AppCoordinator: NavigationCoordinator<AppRoute> {
    
    let modules: [Module]
    
    public init(modules: [Module]) {
        self.modules = modules
        super.init(initialRoute: .userSearch)
        
//        self.modules.forEach({ $0.appRouter = self.anyRouter })
        
    }
    
    //    public override func generateRootViewController() -> UINavigationController {
    //        let navigationController = super.generateRootViewController()
    //        navigationController.navigationBar.prefersLargeTitles = true
    //        return navigationController
    //    }
    
    public override func prepareTransition(for route: AppRoute) -> NavigationTransition {
//        self.modules.first(where: { $0.coordinator(for: route, transition: TransitionType.self)?.hasTransition(for route: $0) })
        if let coordinator = self.coordinator(for: route) {
            return .route(route, on: coordinator)
        } else {
            return .none()
        }
//        switch route {
//        case .userSearch, .repoDetail, .userProfile:
//            return NavigationTransition.route(route, on: <#T##Coordinator#>)
//            return self.coordinator(for: route)?.prepareTransition(for: route) ?? .none()
//        case .externalURL(let url):
//            if let transition = self.coordinator(for: route)?.prepareTransition(for: route) {
//                return transition
//            } else {
//                UIApplication.shared.open(url)
//                return .none()
//            }
//        }
        
//        self.router(for: route).
//        switch route {
//        case .userSearch:
//            if
//                let rootViewController = self.rootViewController.viewControllers.first,
//                let presentableType = self.modules.getFirstPresentableType(for: route),
//                type(of: rootViewController) == presentableType
//            {
//                return NavigationTransition.popToRoot()
//            } else if let presentable = self.modules.getFirstPresentable(for: route) {
//                return NavigationTransition.set([presentable])
//            } else {
//                return .none()
//            }
//
//        case .userProfile, .repoDetail:
//            guard let presentable = self.modules.getFirstPresentable(for: route) else {
//                return .none()
//            }
//            return .push(presentable)
//
//        case .externalURL(let url):
//            UIApplication.shared.open(url)
//            return .none()
//        }
    }
    
    public func coordinator(for route: RouteType) -> AnyOptionalCoordinator<RouteType, TransitionType>? {
        return self.modules.firstCoordinator(for: route, transition: TransitionType.self)
    }

//    public func router<R: Route>(for route: R) -> AnyRouter<R>? {
//        return self.modules.firstRouter(for: route)
//    }
    
}

//public extension Coordinator {
//
//    func coordinator<R: Route, T: TransitionProtocol>(for route: R, transition: T.Type) -> AnyCoordinator<R, T>? {
//        return self.anyCoordinator as? AnyCoordinator<R, T>
//    }
//
//}
//
//public extension Coordinator where Self: OptionalTransition {
//
//    func coordinator<R: Route, T: TransitionProtocol>(for route: R, transition: T.Type) -> AnyCoordinator<R, T>? {
//        guard self.hasTransition(for: route) else { return nil }
//        return self.anyCoordinator as? AnyCoordinator<R, T>
//    }
//
//}
