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
    
    public override func destination<R: Route>(for route: R, router: AnyRouter<R>) -> Destination? {
        switch (route, router) {
        case let (route as AppRoute, router as AnyRouter<AppRoute>):
            switch route {
            case .userSearch:
                let userSearch = UserSearchViewController()
                userSearch.bind(to: UserSearchViewModel(router: router))
                return .presentable(userSearch)
                
            case .userProfile(let owner, let repositories):
                let userProfile = UserProfileViewController()
                let viewModel = UserProfileViewModel(user: owner, repositories: repositories, router: router)
                userProfile.bind(to: viewModel)
                return .presentable(userProfile)
                
            case .repoDetail(let repository):
                let repositoryDetail = RepositoryDetailViewController()
                let viewModel = RepositoryDetailViewModel(repository: repository, router: router)
                repositoryDetail.bind(to: viewModel)
                return .presentable(repositoryDetail)
                
            case .externalURL: return nil
            }
        default:
            return nil
        }
    }
    
}
