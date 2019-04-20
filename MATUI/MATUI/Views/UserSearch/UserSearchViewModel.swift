//
//  UserSearchViewModel.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 25/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import MATKit
import RxSwift
import RxCocoa
import Action
import XCoordinator
import Moya

public class UserSearchViewModel: ViewModelType {
    
//    private var actions: [ActionType] = []
    
    private let disposeBag = DisposeBag()

    public init(router: AnyRouter<AppRoute>, gitHubAPI: GitHubAPI = GitHubAPI()) {
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
            .withLatestFrom(searchAction.inputs, resultSelector: { ($1, $0) })
            .subscribe(onNext: { (login, repositories) in
                guard let owner = repositories.first(where: { $0.owner.login == login })?.owner ?? repositories.first?.owner else {
                    return
                }
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
    
    public var input: Input
    public var output: Output
    
    public struct Input {
        public var search: InputSubject<String?>
    }
    
    public struct Output {
        public var isSearching: Driver<Bool>
        public var error: Signal<Error>
    }
    
    // MARK: -
    
    public enum Error: Swift.Error, Equatable {
        case usernameIsEmpty
        case usernameNotFound
        case unhandledError
        case userDoesNotHaveAnyRepository
    }
    
}
