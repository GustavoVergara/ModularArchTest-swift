//
//  AppCoordinator.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 25/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import XCoordinator

enum AppRoute: Route, Equatable {
    case userSearch
    case userProfile(user: User, repositories: [Repository])
    case repoDetail(Repository)
    case externalURL(URL)
}


class AppCoordinator: NavigationCoordinator<AppRoute> {
    
    init() {
        super.init(initialRoute: .userSearch)
    }
    
//    override func generateRootViewController() -> UINavigationController {
//        let navigationController = super.generateRootViewController()
//        navigationController.navigationBar.prefersLargeTitles = true
//        return navigationController
//    }
    
    override func prepareTransition(for route: AppRoute) -> NavigationTransition {
        switch route {
        case .userSearch:
            if let rootViewController = self.rootViewController.viewControllers.first, rootViewController is UserSearchViewController {
                return NavigationTransition.popToRoot()
            } else {
                let userSearch = UserSearchViewController()
                userSearch.bind(to: UserSearchViewModel(router: self.router(for: route) ?? self.anyRouter))
                return NavigationTransition.set([userSearch])
            }
            
        case .userProfile(let owner, let repositories):
            let userProfile = UserProfileViewController()
            let viewModel = UserProfileViewModel(user: owner, repositories: repositories, router: self.router(for: route) ?? self.anyRouter)
            userProfile.bind(to: viewModel)
            return .push(userProfile)
            
        case .repoDetail(let repository):
            let repositoryDetail = RepositoryDetailViewController()
            let viewModel = RepositoryDetailViewModel(repository: repository, router: self.router(for: route) ?? self.anyRouter)
            repositoryDetail.bind(to: viewModel)
            return .push(repositoryDetail)
            
        case .externalURL(let url):
            UIApplication.shared.open(url)
            return .none()
        }
    }
    
}
