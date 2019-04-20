//
//  SearchListModule.swift
//  MATSearchListModule
//
//  Created by Gustavo Vergara Garcia on 08/04/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import MATKit
import XCoordinator

public class SearchListModule: Module {
    
    public override func destination<R: Route>(for route: R, router: AnyRouter<R>) -> Destination? {
        switch (route, router) {
        case let (route as AppRoute, router as AnyRouter<AppRoute>):
            switch route {
            case .userSearch:
                let userSearchList = SearchListViewController()
                userSearchList.bind(to: SearchListViewModel(router: router))
                return .presentable(userSearchList)
                
            case .userProfile, .repoDetail, .externalURL:
                return nil
            }
        default:
            return nil
        }
    }
    
}
