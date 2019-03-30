//
//  CacheControlPlugin.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 02/03/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import Moya
import Result

struct CacheControlPlugin: PluginType {
    
    static let `default` = CacheControlPlugin(urlCache: URLSessionConfiguration.default.urlCache ?? URLCache())
    
    var urlCache: URLCache
    
    /// Called to modify a result before completion.
    func process(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Result<Moya.Response, MoyaError> {
        guard case let .failure(moyaError) = result else {
            return result
        }
        
        switch moyaError {
        case .underlying(let error as NSError, let response) where error.domain == NSURLErrorDomain:
            let cachedURLResponse = response?.request.flatMap(self.urlCache.cachedResponse)
//                target.
            guard let cachedHTTPURLResponse = cachedURLResponse?.response as? HTTPURLResponse, let data = cachedURLResponse?.data else {
                return result
            }
            let cachedResponse = Moya.Response(statusCode: cachedHTTPURLResponse.statusCode, data: data, request: response?.request, response: cachedHTTPURLResponse)
            return Result.success(cachedResponse)
            
        default:
            return result
        }
    }

}
