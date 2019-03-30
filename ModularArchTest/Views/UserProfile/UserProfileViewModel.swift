//
//  UserProfileViewModel.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 28/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Action
import XCoordinator
import Alamofire
import AlamofireImage

class UserProfileViewModel: ViewModelType {
    
    private let disposeBag = DisposeBag()
    
    init(user: User, repositories: [Repository], router: AnyRouter<AppRoute>) {
        let selectRepositoryAction = Action<Repository, Void>(workFactory: { (repository) in
            return router.rx.trigger(AppRoute.repoDetail(repository))
        })
        Disposables.createStrongReferenceTo(selectRepositoryAction).disposed(by: self.disposeBag)

        let getImageAction = Action<URL?, UIImage>(workFactory: { (imageURL) in
            guard let imageURL = imageURL else {
                return Observable<UIImage>.just(R.image.github_octocat_template()!)
            }
            
            return Alamofire.request(imageURL).rx.responseImage()
                .value()
                .asObservable()
        })
        Disposables.createStrongReferenceTo(getImageAction).disposed(by: self.disposeBag)
        
        let userDriver = Driver.just(user)
        let repositoriesDriver = Driver.just(repositories)
        
        let isGettingProfileImageDriver = getImageAction.executing.asDriver(onErrorJustReturn: false)
        
        let profileImageDriver = userDriver.map({ $0.avatarURL })
            .asObservable()
            .flatMapLatest(getImageAction.execute)
            .asDriver(onErrorJustReturn: R.image.github_octocat_template()!)
        
        self.input = Input(
            selectRepository: selectRepositoryAction.inputs
        )
        
        self.output = Output(
            user: userDriver,
            repositories: repositoriesDriver,
            profileImage: profileImageDriver,
            isGettingProfileImage: isGettingProfileImageDriver
        )
    }
    
    // MARK: - ViewModelType
    
    var input: Input
    var output: Output
    
    struct Input {
        var selectRepository: InputSubject<Repository>
    }
    
    struct Output {
        var user: Driver<User>
        var repositories: Driver<[Repository]>
        var profileImage: Driver<UIImage>
        var isGettingProfileImage: Driver<Bool>
        
        var username: Driver<String> { return self.user.map({ $0.login }) }
    }

}
