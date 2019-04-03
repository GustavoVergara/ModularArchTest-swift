//
//  APIError.swift
//  MATKit
//
//  Created by Gustavo Vergara Garcia on 02/04/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import Moya

public enum APIError {
    /// Indicates a response failed to map to an image.
    case imageMapping(Moya.Response)
    
    /// Indicates a response failed to map to a JSON structure.
    case jsonMapping(Moya.Response)
    
    /// Indicates a response failed to map to a String.
    case stringMapping(Moya.Response)
    
    /// Indicates a response failed to map to a Decodable object.
    case objectMapping(Error, Moya.Response)
    
    /// Indicates that Encodable couldn't be encoded into Data
    case encodableMapping(Error)
    
    /// Indicates a response failed with an invalid HTTP status code.
    case statusCode(Moya.Response)
    
    /// Indicates a response failed due to an underlying `Error`.
    case underlying(Error, Moya.Response?)
    
    /// Indicates that an `Endpoint` failed to map to a `URLRequest`.
    case requestMapping(String)
    
    /// Indicates that an `Endpoint` failed to encode the parameters for the `URLRequest`.
    case parameterEncoding(Error)
}
