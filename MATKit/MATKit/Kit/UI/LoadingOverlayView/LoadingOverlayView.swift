//
//  LoadingOverlayView.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 25/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import UIKit

public class LoadingOverlayView: UIView {
    
    public let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    public let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    public init() {
        super.init(frame: .zero)
        
        self.prepareViews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.prepareViews()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.blurView.frame = self.bounds
        self.activityIndicator.center = self.center
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let superview = self.superview {
            self.frame = superview.bounds
        }
    }
    
    public func prepareViews() {
        self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.backgroundColor = .clear
        
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.startAnimating()
        
        self.addSubview(self.blurView)
        self.addSubview(self.activityIndicator)
    }
    
}

extension UIView: UtilsCompatible {}

extension UtilsWrapper where Base: UIView {
    
    public var hasLoadingOverlay: Bool {
        return self.base.subviews.contains(where: { $0 is LoadingOverlayView })
    }
    
    public func addLoadingOverlay() {
        guard self.hasLoadingOverlay == false else { return }
        let loadingView = LoadingOverlayView()
        self.base.addSubview(loadingView)
    }
    
    public func removeLoadingOverlay() {
        self.base.subviews.forEach({ ($0 as? LoadingOverlayView)?.removeFromSuperview() })
    }
    
}
