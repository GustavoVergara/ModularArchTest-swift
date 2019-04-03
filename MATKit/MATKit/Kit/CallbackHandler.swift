//
//  CallbackHandler.swift
//
//  Created by Gustavo Vergara Garcia on 07/11/18.
//

import Foundation

public enum Callback {
    
    public class DisposeBag {
        
        var cancellers: [Canceller] = []
        
        deinit {
            self.dispose()
        }
        
        public func add(_ canceller: Canceller) {
            self.cancellers.append(canceller)
        }
        
        public func dispose() {
            self.cancellers.forEach({ $0.cancel() })
            self.cancellers = []
        }
        
    }
    
    public struct Canceller {
        public let cancel: () -> Void
        
        public init(cancel: @escaping () -> Void) {
            self.cancel = cancel
        }
    }
    
    public typealias HandlerToken = UInt
    public struct Handlers<T>: Sequence, ExpressibleByArrayLiteral {
        
        public typealias KeyValue = (key: HandlerToken, value: T)
        
        private var currentKey: HandlerToken = 0
        private var elements = [KeyValue]()
        
        /// The type of the elements of an array literal.
        public typealias ArrayLiteralElement = T
        
        /// Creates an instance initialized with the given elements.
        public init(arrayLiteral elements: ArrayLiteralElement...) {
            for element in elements {
                _ = self.append(element)
            }
        }
        
        public mutating func append(_ value: T) -> HandlerToken {
            self.currentKey = self.currentKey &+ 1
            
            self.elements.append((key: self.currentKey, value: value))
            
            return self.currentKey
        }
        
        @discardableResult
        public mutating func remove(_ token: HandlerToken) -> T? {
            for i in self.elements.indices where self.elements[i].key == token {
                return self.elements.remove(at: i).value
            }
            return nil
        }
        
        public mutating func removeAll(keepCapacity: Bool = false) {
            self.elements.removeAll(keepingCapacity: keepCapacity)
        }
        
        public func makeIterator() -> AnyIterator<T> {
            return AnyIterator(self.elements.map { $0.value }.makeIterator())
        }
    }

}
