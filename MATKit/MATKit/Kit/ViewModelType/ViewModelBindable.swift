//
//  ViewModelBindable.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 25/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation

public protocol ViewModelBindable {
    associatedtype ViewModel: ViewModelType
    
    func bind(to viewModel: ViewModel)
}
