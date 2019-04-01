//
//  UIModule.swift
//  MATUI
//
//  Created by Gustavo Vergara Garcia on 30/03/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import MATKit
import XCoordinator

public class UIModule: Module {
    
    let appCoordinator = UICoordinator(initialRoute: .userSearch)
    
//    public override func router<R: Route>(for route: R) -> AnyRouter<R>? {
//        switch route {
//        case let route as AppRoute:
//            switch route {
//            case .userSearch, .userProfile, .repoDetail:
//                return self.appCoordinator.anyRouter as? AnyRouter<R>
//            case .externalURL:
//                return nil
//            }
//        default:
//            return nil
//        }
//    }
    
    public override func coordinator<R: Route, T: TransitionProtocol>(for route: R, transition: T.Type) -> AnyOptionalCoordinator<R, T>? {
        switch route {
        case let route as AppRoute where self.appCoordinator.hasTransition(for: route):
            return self.appCoordinator.anyOptionalCoordinator as? AnyOptionalCoordinator<R, T>
        default:
            return nil
        }
    }
    
//    private func coordinator<R: Route, T: TransitionProtocol>(routeType: R.Type, transitionType: T.Type) -> AnyOptionalCoordinator<R, T>? {
//        if routeType == AppRoute.self {
//            return self.appCoordinator.anyOptionalCoordinator as? AnyOptionalCoordinator<R, T>
//        } else {
//            return nil
//        }
//    }
//    
//    public override func getPresentableType(for route: AppRoute) -> Any.Type? {
//        switch route {
//        case .userSearch:
//            return UserSearchViewController.self
//        case .userProfile:
//            return UserProfileViewController.self
//        case .repoDetail:
//            return RepositoryDetailViewController.self
//        case .externalURL: return nil
//        }
//    }
//
//    public override func getPresentable(for route: AppRoute) -> Presentable? {
//        guard let appRouter = self.appRouter else { return nil }
//        switch route {
//        case .userSearch:
//            let viewController = UserSearchViewController()
//            viewController.bind(to: UserSearchViewModel(router: appRouter))
//            return viewController
//        case .userProfile(let owner, let repositories):
//            let userProfile = UserProfileViewController()
//            let viewModel = UserProfileViewModel(user: owner, repositories: repositories, router: appRouter)
//            userProfile.bind(to: viewModel)
//            return userProfile
//
//        case .repoDetail(let repository):
//            let repositoryDetail = RepositoryDetailViewController()
//            let viewModel = RepositoryDetailViewModel(repository: repository, router: appRouter)
//            repositoryDetail.bind(to: viewModel)
//            return repositoryDetail
//        case .externalURL: return nil
//        }
//    }
//
//    public override func getTransition<T: TransitionProtocol>(for route: Route, type: T.Type) -> T? {
//        return nil
//    }
    
}

public class UICoordinator: NavigationCoordinator<AppRoute>, OptionalTransition {
    
    public func hasTransition(for route: RouteType) -> Bool {
        switch route {
        case .userSearch, .userProfile, .repoDetail:
            return true
        case .externalURL:
            return false
        }
    }
    
    public override func prepareTransition(for route: AppRoute) -> NavigationTransition {
        switch route {
        case .userSearch:
            let viewController = UserSearchViewController()
            viewController.bind(to: UserSearchViewModel(router: self.anyRouter))
            return .push(viewController)
            
        case .userProfile(let owner, let repositories):
            let userProfile = UserProfileViewController()
            let viewModel = UserProfileViewModel(user: owner, repositories: repositories, router: self.anyRouter)
            userProfile.bind(to: viewModel)
            return .push(userProfile)
            
        case .repoDetail(let repository):
            let repositoryDetail = RepositoryDetailViewController()
            let viewModel = RepositoryDetailViewModel(repository: repository, router: self.anyRouter)
            repositoryDetail.bind(to: viewModel)
            return .push(repositoryDetail)
        case .externalURL: return .none()
        }
    }
    
}
