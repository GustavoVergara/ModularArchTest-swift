//
//  RxResource.swift
//  MATKit
//
//  Created by Gustavo Vergara Garcia on 20/04/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import UIKit

#if canImport(RxSwift)
import RxSwift

public typealias RxImage = RxResource<UIImage>

public struct RxResource<Element> {
    public let resource: Observable<Element>
    public let isGettingResource: Observable<Bool>
    
    private let disposeBag = DisposeBag()
    
    public init(resourceObservable: Observable<Element>, isGettingResource: Observable<Bool>) {
        self.resource = resourceObservable.share(replay: 1, scope: .forever)
        self.isGettingResource = isGettingResource.share(replay: 1, scope: .forever)
    }
    
    public init(resource: Element) {
        self.init(resourceObservable: .just(resource), isGettingResource: .just(false))
    }
    
    public func prefetch() {
        self.resource.subscribe().disposed(by: self.disposeBag)
    }
    
}

#if canImport(Action)
import Action

extension RxResource {

    public init<Input>(input: Input, action: Action<Input, Element>) {
        let resourceObservable = Observable.deferred({ action.execute(input) })
        let isGettingResource = action.executing
        self.init(resourceObservable: resourceObservable, isGettingResource: isGettingResource)
        Disposables.createStrongReferenceTo(action).disposed(by: self.disposeBag)
    }

}
#endif
#endif
