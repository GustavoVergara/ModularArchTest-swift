//
//  Rx+LoadingOverlayView.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 25/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public extension Reactive where Base: UIView {
    
    var hasLoadingOverlay: Binder<Bool> {
        return Binder<Bool>(self.base, scheduler: MainScheduler.instance, binding: { (view, hasLoadingOverlay) in
            if hasLoadingOverlay {
                view.utils.addLoadingOverlay()
            } else {
                view.utils.removeLoadingOverlay()
            }
        })
    }
    
}
