//
//  AppCoordinator.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 25/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import XCoordinator

public enum AppRoute: Route, Hashable {
    case userSearch
    case userProfile(user: User, repositories: [Repository])
    case repoDetail(Repository)
    case externalURL(URL)
}
