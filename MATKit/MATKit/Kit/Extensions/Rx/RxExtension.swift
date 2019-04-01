//
//  RxExtension.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 25/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public extension PrimitiveSequenceType where TraitType == SingleTrait {
    
    func `do`(
        onSuccess: ((ElementType) throws -> Void)? = nil,
        onError: ((Swift.Error) throws -> Void)? = nil,
        onFinished: (() -> ())? = nil,
        onSubscribe: (() -> ())? = nil,
        onSubscribed: (() -> ())? = nil,
        onDispose: (() -> ())? = nil)
        -> Single<ElementType> {
            return self.do(
                onSuccess: onSuccess,
                onError: onError,
                onSubscribe: onSubscribe,
                onSubscribed: onSubscribed,
                onDispose: onDispose
            )
            .do(
                onSuccess: { _ in onFinished?() },
                onError: { _ in  onFinished?() }
            )
    }
    
}

public extension SharedSequenceConvertibleType {
    
    func take(_ count: Int) -> SharedSequence<SharingStrategy, E> {
        return self.asObservable()
            .take(count)
            .asSharedSequence(onErrorDriveWith: .empty())
    }
    
    func concat<SS: SharedSequenceConvertibleType>(_ second: SS) -> SharedSequence<SS.SharingStrategy, SS.E> where E == SS.E {
        return self.asObservable()
            .concat(second.asObservable())
            .asSharedSequence(onErrorDriveWith: .empty())
    }
    
    func concatMap<SS: SharedSequenceConvertibleType>(_ selector: @escaping (E) throws -> SS) -> SharedSequence<SS.SharingStrategy, SS.E> {
        return self.asObservable()
            .concatMap({ try selector($0).asObservable() })
            .asSharedSequence(onErrorDriveWith: .empty())
    }
    
}

public extension ObservableType {
    
    func ignoreValues() -> Observable<Void> {
        return self.map({ _ in () })
    }
    
}

public extension SharedSequenceConvertibleType {

    func ignoreValues() -> SharedSequence<SharingStrategy, Void> {
        return self.map({ _ in () })
    }
    
}

public extension Disposables {
    
    static func createStrongReferenceTo(_ any: Any) -> Cancelable {
        var strongAny: Any? = any
        return Disposables.create(with: { _ = strongAny; strongAny = nil })
    }
    
}
