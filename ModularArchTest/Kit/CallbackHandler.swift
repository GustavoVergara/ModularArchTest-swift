//
//  CallbackHandler.swift
//
//  Created by Gustavo Vergara Garcia on 07/11/18.
//

import Foundation

enum Callback {
    
    class DisposeBag {
        
        var cancellers: [Canceller] = []
        
        deinit {
            self.dispose()
        }
        
        func add(_ canceller: Canceller) {
            self.cancellers.append(canceller)
        }
        
        func dispose() {
            self.cancellers.forEach({ $0.cancel() })
            self.cancellers = []
        }
        
    }
    
    struct Canceller {
        let cancel: () -> Void
        
        init(cancel: @escaping () -> Void) {
            self.cancel = cancel
        }
    }
    
    typealias HandlerToken = UInt
    struct Handlers<T>: Sequence, ExpressibleByArrayLiteral {
        
        typealias KeyValue = (key: HandlerToken, value: T)
        
        private var currentKey: HandlerToken = 0
        private var elements = [KeyValue]()
        
        /// The type of the elements of an array literal.
        typealias ArrayLiteralElement = T
        
        /// Creates an instance initialized with the given elements.
        init(arrayLiteral elements: ArrayLiteralElement...) {
            for element in elements {
                _ = self.append(element)
            }
        }
        
        mutating func append(_ value: T) -> HandlerToken {
            self.currentKey = self.currentKey &+ 1
            
            self.elements.append((key: self.currentKey, value: value))
            
            return self.currentKey
        }
        
        @discardableResult
        mutating func remove(_ token: HandlerToken) -> T? {
            for i in self.elements.indices where self.elements[i].key == token {
                return self.elements.remove(at: i).value
            }
            return nil
        }
        
        mutating func removeAll(keepCapacity: Bool = false) {
            self.elements.removeAll(keepingCapacity: keepCapacity)
        }
        
        func makeIterator() -> AnyIterator<T> {
            return AnyIterator(self.elements.map { $0.value }.makeIterator())
        }
    }

}
