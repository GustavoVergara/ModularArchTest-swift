//
//  UIViewControllerExtensions.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 26/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController: UtilsCompatible {}
public extension UtilsWrapper where Base: UIViewController {
    
    func presentAlert(title: String? = nil, message: String? = nil, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(.init(title: "OK", style: .default, handler: { [weak alertController] _ in
            completion?()
            alertController?.dismiss(animated: true)
        }))
        self.base.present(alertController, animated: true)
    }
    
}
