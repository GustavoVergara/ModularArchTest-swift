//
//  DataResponse+Rx.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 28/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

public extension PrimitiveSequenceType where TraitType == SingleTrait, ElementType: DataResponseType {
    
    func value() -> Single<ElementType.Value> {
        return self.flatMap({ (response) in
            switch response.result {
            case .success(let value):
                return Single.just(value)
            case .failure(let error):
                return Single.error(error)
            }
        })
    }
    
}
