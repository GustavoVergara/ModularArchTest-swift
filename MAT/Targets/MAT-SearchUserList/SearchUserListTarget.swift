//
//  SearchUserListTarget.swift
//  MAT
//
//  Created by Gustavo Vergara Garcia on 18/04/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import XCoordinator
import MATKit
import MATSearchListModule
import MATUI

struct SearchUserListTarget: Target {
    
    var modules: [Module]
    var mainCoordinator: NavigationCoordinator<AppRoute>

    init() {
        self.modules = [CoreModule(), SearchListModule(), UIModule()]
        self.mainCoordinator = CoreCoordinator(modules: self.modules)
    }
    
}

