//
//  NetworkActivityIndicatorPlugin.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 25/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import UIKit
import Moya
import Result

class NetworkActivityIndicatorPlugin: PluginType {
    
    static let `default` = NetworkActivityIndicatorPlugin(application: UIApplication.shared)
    
    private weak var application: UIApplication?
    
    private var count: Int = 0 {
        didSet {
            UIApplication.shared.isNetworkActivityIndicatorVisible = self.count > 0
        }
    }
    
    init(application: UIApplication = UIApplication.shared) {
        self.application = application
    }
    
    /// Called immediately before a request is sent over the network (or stubbed).
    func willSend(_ request: RequestType, target: TargetType) {
        DispatchQueue.main.async {
            self.count += 1
        }
    }
    
    /// Called after a response has been received, but before the MoyaProvider has invoked its completion handler.
    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        DispatchQueue.main.async {
            self.count -= 1
        }
    }
    
}
