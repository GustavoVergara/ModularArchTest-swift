//
//  UserSearchViewModel.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 25/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import XCoordinator
import Moya

class UserSearchViewModel: ViewModelType {
    
//    private var actions: [ActionType] = []
    
    private let disposeBag = DisposeBag()

    init(router: AnyRouter<AppRoute>, gitHubAPI: GitHubAPI = GitHubAPI()) {
        let searchAction = Action<String?, [Repository]>(workFactory: { (username) -> Observable<[Repository]> in
            guard let username = username, username.isEmpty == false else {
                return .error(Error.usernameIsEmpty)
            }
            return gitHubAPI.getRepositories(ownerUsername: username)
                .flatMap({ (repositories) -> Single<[Repository]> in
                    guard repositories.isEmpty == false else {
                        return .error(Error.userDoesNotHaveAnyRepository)
                    }
                    return .just(repositories)
                })
                .asObservable()
//                .do(onNext: { (repositories) in
//                    guard let onwer = repositories.first?.owner else { return }
//                    router.trigger(.userProfile(user: onwer, repositories: repositories))
//                })
        })
        Disposables.createStrongReferenceTo(searchAction).disposed(by: self.disposeBag)
        
        let isSearchingDriver = searchAction.executing.asDriver(onErrorJustReturn: false)
        
        let errorSignal = searchAction.errors
            .map({ (actionError) -> Error in
                switch actionError.underlying {
                case let error as Error:
                    return error
                case let error as MoyaError:
                    switch error {
                    case .statusCode(let response) where response.statusCode == 404:
                        return .usernameNotFound
                    default: break
                    }
                default: break
                }
                // default
                return .unhandledError
            })
            .asSignal(onErrorSignalWith: .empty())
        
        searchAction.elements
            .subscribe(onNext: { (repositories) in
                guard let owner = repositories.first?.owner else { return }
                router.trigger(.userProfile(user: owner, repositories: repositories))
            })
            .disposed(by: self.disposeBag)
        
        self.input = Input(
            search: searchAction.inputs
        )
        
        self.output = Output(
            isSearching: isSearchingDriver,
            error: errorSignal
        )
    }
    
    // MARK: - ViewModelType
    
    var input: Input
    var output: Output
    
    struct Input {
        var search: InputSubject<String?>
    }
    
    struct Output {
        var isSearching: Driver<Bool>
        var error: Signal<Error>
    }
    
    // MARK: -
    
    enum Error: Swift.Error, Equatable {
        case usernameIsEmpty
        case usernameNotFound
        case unhandledError
        case userDoesNotHaveAnyRepository
    }
    
}
