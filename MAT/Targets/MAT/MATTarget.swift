//
//  MATTarget.swift
//  MAT
//
//  Created by Gustavo Vergara Garcia on 08/04/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import XCoordinator
import MATKit
import MATUI

struct MATTarget: Target {
    
    var modules: [Module]
    var mainCoordinator: NavigationCoordinator<AppRoute>
    
    init() {
        self.modules = [CoreModule(), UIModule()]
        self.mainCoordinator = CoreCoordinator(modules: self.modules)
    }
    
}
