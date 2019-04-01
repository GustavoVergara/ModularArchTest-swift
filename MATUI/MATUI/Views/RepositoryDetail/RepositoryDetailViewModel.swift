//
//  RepositoryDetailViewModel.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 01/03/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import MATKit
import RxSwift
import RxCocoa
import Action
import XCoordinator

public class RepositoryDetailViewModel: ViewModelType {
    
    let disposeBag = DisposeBag()
    
    public init(repository: Repository, router: AnyRouter<AppRoute>, gitHubAPI: GitHubAPI = GitHubAPI()) {
        let repositoryDriver = Driver<Repository>.just(repository).concat(Driver.never())
        let canOpenOnGitHubDriver = repositoryDriver.map({ $0.htmlURL != nil })
        
        let openOnGitHubAction = Action<Void, Void>(enabledIf: canOpenOnGitHubDriver.asObservable()) {
            guard let url = repository.htmlURL else { return .empty() }
            return router.rx.trigger(.externalURL(url))
        }
        Disposables.createStrongReferenceTo(openOnGitHubAction).disposed(by: self.disposeBag)

        let getIssuesAction = Action<Repository, SearchResult<Issue>>(workFactory: gitHubAPI.searchIssues)
        Disposables.createStrongReferenceTo(getIssuesAction).disposed(by: self.disposeBag)

        let totalIssuesCountDriver = Driver<Int?>.deferred {
            return repositoryDriver.asObservable()
                .flatMapLatest(getIssuesAction.execute)
                .map({ $0.totalCount })
                .catchErrorJustReturn(nil)
                .asDriver(onErrorDriveWith: .empty())
                .startWith(nil)
        }

        self.input = Input(
            openOnGitHub: openOnGitHubAction.inputs
        )
        
        self.output = Output(
            repository: repositoryDriver,
            canOpenOnGitHub: canOpenOnGitHubDriver,
            totalIssuesCount: totalIssuesCountDriver,
            isGettingIssues: getIssuesAction.executing.asDriver(onErrorJustReturn: false)
        )
    }
    
    // MARK: - ViewModelType
    
    public var input: Input
    public var output: Output
    
    public struct Input {
        public var openOnGitHub: InputSubject<Void>
    }
    
    public struct Output {
        public var repository: Driver<Repository>
        public var canOpenOnGitHub: Driver<Bool>
        public var totalIssuesCount: Driver<Int?>
        public var isGettingIssues: Driver<Bool>
    }
    
}
