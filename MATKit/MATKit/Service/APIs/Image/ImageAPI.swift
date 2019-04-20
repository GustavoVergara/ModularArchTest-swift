//
//  ImageAPI.swift
//  MATKit
//
//  Created by Gustavo Vergara Garcia on 08/04/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import Action

public struct ImageAPI {
    
    public var action: Action<URL, UIImage> {
        return Action<URL, UIImage>(workFactory: { self.getImage(from: $0).asObservable() })
    }
    
    let imageProvider: MoyaProvider<ImageTarget>
    
    public init(
        gitHubProvider: MoyaProvider<ImageTarget> = MoyaProvider(plugins: [NetworkActivityIndicatorPlugin.default, CacheControlPlugin.default])
        ) {
        self.imageProvider = gitHubProvider
    }
    
    public func getImage(from url: URL) -> Single<UIImage> {
        return self.imageProvider.rx.request(.init(url: url))
            .mapImage()
            .flatMap({ image in
                if let image = image {
                    return .just(image)
                } else {
                    return .error(RxOptionalError.foundNilWhileUnwrappingOptional(Image.self))
                }
            })
    }
    
}
