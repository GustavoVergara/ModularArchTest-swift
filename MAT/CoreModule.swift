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
    
    override func destination<R: Route>(for route: R, router: AnyRouter<R>) -> Destination? {
        switch (route, router) {
        case let (route as AppRoute, _):
            switch route {
            case .externalURL(let url):
                return Destination.action({
                    UIApplication.shared.open(url)
                })
            case .userSearch, .repoDetail, .userProfile:
                return nil
            }
        default:
            return nil
        }
    }
    
}
