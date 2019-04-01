//
//  UtilsWrapper.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 25/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation

public struct UtilsWrapper<Base> {
    let base: Base
}

public protocol UtilsCompatible {}
public extension UtilsCompatible {
    
    typealias Utils = UtilsWrapper<Self>
    
    var utils: UtilsWrapper<Self> {
        return UtilsWrapper<Self>(base: self)
    }
    
}
