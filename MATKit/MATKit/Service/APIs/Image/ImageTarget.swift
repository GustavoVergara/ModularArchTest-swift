//
//  ImageTarget.swift
//  MATKit
//
//  Created by Gustavo Vergara Garcia on 08/04/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import Moya

public struct ImageTarget: TargetType {
    
    /// The target's base `URL`.
    public var baseURL: URL
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String
    
    /// The HTTP method used in the request.
    public var method: Moya.Method
    
    /// Provides stub data for use in testing.
    public var sampleData: Data
    
    /// The type of HTTP task to be performed.
    public var task: Moya.Task
    
    /// The type of validation to perform on the request. Default is `.none`.
    public var validationType: Moya.ValidationType
    
    /// The headers to be used in the request.
    public var headers: [String : String]?

}

public extension ImageTarget {
    
    init(url: URL) {
        self.baseURL = url.baseURL ?? url
        self.path = url.path
        self.method = .get
        self.sampleData = Data()
        self.task = .requestPlain
        self.validationType = .none
        self.headers = nil
    }
    
}
