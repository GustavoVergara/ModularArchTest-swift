//
//  Alamofire+DataResponseType.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 28/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import Alamofire

protocol DataResponseType {
    associatedtype Value
    
    var result: Result<Value> { get }
    var value: Value? { get }
    var error: Error? { get }
}
extension DataResponse: DataResponseType {}
