//
//  JSONDecoderExtension.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 26/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation

public extension JSONDecoder {
    
    convenience init(
        dateDecodingStrategy: DateDecodingStrategy = .deferredToDate,
        dataDecodingStrategy: DataDecodingStrategy = .base64,
        nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy = .throw,
        userInfo: [CodingUserInfoKey : Any] = [:]) {
        
        self.init()
        self.dateDecodingStrategy = dateDecodingStrategy
        self.dataDecodingStrategy = dataDecodingStrategy
        self.nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy
        self.userInfo = userInfo
    }
    
}

public extension JSONEncoder {
    
    convenience init(
        dateEncodingStrategy: DateEncodingStrategy = .deferredToDate,
        dataEncodingStrategy: DataEncodingStrategy = .base64,
        nonConformingFloatDecodingStrategy: NonConformingFloatEncodingStrategy = .throw,
        userInfo: [CodingUserInfoKey : Any] = [:]) {
        
        self.init()
        self.dateEncodingStrategy = dateEncodingStrategy
        self.dataEncodingStrategy = dataEncodingStrategy
        self.nonConformingFloatEncodingStrategy = nonConformingFloatDecodingStrategy
        self.userInfo = userInfo
    }
    
}

public extension Decodable {
    
    init(fromDictionary dictionary: [String: Any]) throws {
        let decoder = JSONDecoder()
        
        self = try decoder.decode(Self.self, from: JSONSerialization.data(withJSONObject: dictionary))
    }
    
}

public extension Encodable {
    
    func toDictionary() -> [String: Any] {
        let encoder = JSONEncoder()
        
        return (try? encoder.encode(self))
            .flatMap({ try? JSONSerialization.jsonObject(with: $0) })
            .flatMap({ $0 as? [String: Any] })
            ?? [:]
    }
    
}

public extension UserDefaults {
    
    func decodable<D: Decodable>(_ decodable: D.Type, forKey key: String) -> D? {
        guard let rawData = self.data(forKey: key) else { return nil }
        
        return try? JSONDecoder().decode(decodable, from: rawData)
    }
    
    func set<E: Encodable>(encodable value: E?, forKey key: String) {
        guard let value = value else {
            self.setValue(nil, forKey: key)
            return
        }
        
        self.setValue(try? JSONEncoder().encode(value), forKey: key)
    }
    
}

extension JSONDecoder.DateDecodingStrategy {
    
    static func iso8601(formatOptions: ISO8601DateFormatter.Options) -> JSONDecoder.DateDecodingStrategy {
        return .custom({ (decoder) -> Date in
            let singleValueContainer = try decoder.singleValueContainer()
            let dateString = try singleValueContainer.decode(String.self)
            
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = formatOptions
            
            guard let date = isoFormatter.date(from: dateString) else { throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Not able to parse date")) }
            return date
        })
    }
    
}
