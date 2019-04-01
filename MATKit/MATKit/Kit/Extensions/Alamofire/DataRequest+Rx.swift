//
//  DataRequest+Rx.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 28/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import RxSwift

extension DataRequest: ReactiveCompatible {}
public extension Reactive where Base: DataRequest {
    
    func responseImage(imageScale: CGFloat = DataRequest.imageScale, inflateResponseImage: Bool = true) -> Single<DataResponse<Image>> {
        return Single.create(subscribe: { [weak base] (eventHandler) -> Disposable in
            base?.responseImage(
                imageScale: imageScale,
                inflateResponseImage: inflateResponseImage,
                queue: nil,
                completionHandler: { (dataResponse) in
                    eventHandler(.success(dataResponse))
            }
            )
            
            return Disposables.create {
                base?.cancel()
            }
        })
    }
    
}
