//
//  TestCoordinator.swift
//  ModularArchTestTestsTests
//
//  Created by Gustavo Vergara Garcia on 27/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import XCoordinator
import RxSwift
import MATKit
@testable import MATUI

class TestAppCoordinator: NavigationCoordinator<AppRoute> {
    typealias TriggerCallback = (RouteType) -> Void
    
    private var onTriggerCallbacks: Callback.Handlers<TriggerCallback> = []
    
    // MARK: - XCoordinator
    
    override func prepareTransition(for route: AppRoute) -> NavigationTransition {
        self.didTrigger(route)
        return .none()
    }
    
    // MARK: - Methods
    
    @discardableResult
    func onTrigger(_ handler: @escaping TriggerCallback) -> Callback.Canceller {
        let handlerToken = self.onTriggerCallbacks.append(handler)
        return Callback.Canceller(cancel: {
            self.onTriggerCallbacks.remove(handlerToken)
        })
    }
    
    private func didTrigger(_ route: AppRoute) {
        self.onTriggerCallbacks.forEach({ $0(route) })
    }
    
}


extension Reactive where Base: TestAppCoordinator {
    
    func onTrigger() -> Observable<Base.RouteType> {
        return Observable.create({ [weak base] (observer) -> Disposable in
            let canceller = base?.onTrigger({ (route) in
                observer.onNext(route)
            })
            
            return Disposables.create {
                canceller?.cancel()
            }
        })
        .share()
    }
    
}
