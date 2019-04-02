//
//  OptionalCoordinator.swift
//  MATKit
//
//  Created by Gustavo Vergara Garcia on 01/04/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

/// ------
/// UNUSED
/// ------

import Foundation
import UIKit
import XCoordinator

public protocol OptionalTransition: Coordinator {
    func hasTransition(for route: RouteType) -> Bool
}

public extension Coordinator where Self: OptionalTransition {
    
    /// Creates an AnyCoordinator based on the current coordinator.
    var anyOptionalCoordinator: AnyOptionalCoordinator<RouteType, TransitionType> {
        return AnyOptionalCoordinator(self)
    }
    
}

/// An type-erased Coordinator (`AnyCoordinator`) with a `UINavigationController` as rootViewController.
public typealias AnyOptionalNavigationCoordinator<RouteType: Route> = AnyOptionalCoordinator<RouteType, NavigationTransition>

/// An type-erased Coordinator (`AnyCoordinator`) with a `UITabBarController` as rootViewController.
public typealias AnyOptionalTabBarCoordinator<RouteType: Route> = AnyOptionalCoordinator<RouteType, TabBarTransition>

/// An type-erased Coordinator (`AnyCoordinator`) with a `UIViewController` as rootViewController.
public typealias AnyOptionalViewCoordinator<RouteType: Route> = AnyOptionalCoordinator<RouteType, ViewTransition>

///
/// `AnyCoordinator` is a type-erased `Coordinator` (`RouteType` & `TransitionType`) and
/// can be used as an abstraction from a specific coordinator class while still specifying
/// TransitionType and RouteType.
///
/// - Note:
///     If you do not want/need to specify TransitionType, you might want to look into the `AnyRouter` class.
///     See `AnyTransitionPerformer` to further abstract from RouteType.
///
public class AnyOptionalCoordinator<RouteType: Route, TransitionType: TransitionProtocol>: Coordinator, OptionalTransition {
    
    // MARK: - Stored properties
    
    private let _prepareTransition: (RouteType) -> TransitionType
    private let _rootViewController: () -> TransitionType.RootViewController
    private let _presented: (Presentable?) -> Void
    private let _setRoot: (UIWindow) -> Void
    private let _hasTransition: (RouteType) -> Bool
    
    // MARK: - Initialization
    
    ///
    /// Creates a type-erased Coordinator for a specific coordinator.
    ///
    /// A strong reference to the source coordinator is kept.
    ///
    /// - Parameter coordinator:
    ///     The source coordinator.
    ///
    public init<C: Coordinator & OptionalTransition>(_ coordinator: C) where C.RouteType == RouteType, C.TransitionType == TransitionType {
        self._prepareTransition = coordinator.prepareTransition
        self._rootViewController = { coordinator.rootViewController }
        self._presented = coordinator.presented
        self._setRoot = coordinator.setRoot
        self._hasTransition = coordinator.hasTransition
    }
    
    // MARK: - Computed properties
    
    public var rootViewController: TransitionType.RootViewController {
        return _rootViewController()
    }
    
    // MARK: - Methods
    
    ///
    /// Prepare and return transitions for a given route.
    ///
    /// - Parameter route:
    ///     The triggered route for which a transition is to be prepared.
    ///
    /// - Returns:
    ///     The prepared transition.
    ///
    public func prepareTransition(for route: RouteType) -> TransitionType {
        return _prepareTransition(route)
    }
    
    public func presented(from presentable: Presentable?) {
        _presented(presentable)
    }
    
    public func setRoot(for window: UIWindow) {
        _setRoot(window)
    }
    
    public func hasTransition(for route: RouteType) -> Bool {
        return _hasTransition(route)
    }
    
}
