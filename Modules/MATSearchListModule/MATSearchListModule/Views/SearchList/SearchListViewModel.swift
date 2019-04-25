//
//  SearchListViewModel.swift
//  MATSearchListModule
//
//  Created by Gustavo Vergara Garcia on 03/04/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import MATKit
import RxSwift
import RxCocoa
import Action
import XCoordinator
import Moya

public class SearchListViewModel: ViewModelType {
    
    private let disposeBag = DisposeBag()
    
    public init(router: AnyRouter<AppRoute>, gitHubAPI: GitHubAPI = GitHubAPI(), imageAPI: ImageAPI = ImageAPI()) {
        let pageControl = PageControl<User>()
        Disposables.createStrongReferenceTo(pageControl).disposed(by: self.disposeBag)
        
        var lastSearch: String?
        let searchAction = Action<String?, SearchResult<User>>(workFactory: { (login) in
            lastSearch = login
            return gitHubAPI.searchUsers(login: login ?? "")
                .asObservable()
        })
        Disposables.createStrongReferenceTo(searchAction).disposed(by: self.disposeBag)
        let isSearchingUsersDriver = searchAction.executing.asDriver(onErrorJustReturn: false)
        
        let getNextUsersPageAction = Action<Void, SearchResult<User>>(workFactory: {
            guard let lastSearch = lastSearch else { return .empty() }
            return gitHubAPI.searchUsers(login: lastSearch, page: (pageControl.availablePages.last ?? 0) + 1)
                .asObservable()
        })
        Disposables.createStrongReferenceTo(getNextUsersPageAction).disposed(by: self.disposeBag)
        let isGettingMoreUsersDriver = getNextUsersPageAction.executing.asDriver(onErrorJustReturn: false)
        
        let selectUserAction = Action<User, [Repository]>(workFactory: { (user) -> Observable<[Repository]> in
            return gitHubAPI.getRepositories(ownerUsername: user.login)
                .catchError({ (apiError) -> PrimitiveSequence<SingleTrait, [Repository]> in
                    guard let error = apiError as? MoyaError else {
                        return .error(apiError)
                    }
                    switch error {
                    case .statusCode(let response) where response.statusCode == 404:
                        return .error(Error.loginNotFound)
                    default:
                        return .error(apiError)
                    }
                })
                .asObservable()
        })
        Disposables.createStrongReferenceTo(selectUserAction).disposed(by: self.disposeBag)
        let isSearchingRepositoriesDriver = selectUserAction.executing.asDriver(onErrorJustReturn: false)
        
        searchAction.elements
            .ignoreValues()
            .bind(to: pageControl.rx.clear)
            .disposed(by: self.disposeBag)
        
        searchAction.elements
            .map({ ($0.items, 1) })
            .bind(to: pageControl.rx.insert)
            .disposed(by: self.disposeBag)
        
        getNextUsersPageAction.elements
            .map({ $0.items })
            .bind(to: pageControl.rx.add)
            .disposed(by: self.disposeBag)
        
        let usersDriver = pageControl.rx.elements.asDriver(onErrorJustReturn: [])
        
        let imagesDriver = usersDriver
            .map { (users) -> [URL: RxImage] in
                var images = [URL: RxImage]()
                for user in users {
                    guard let avatarURL = user.avatarURL else { continue }
                    images[avatarURL] = RxImage(input: avatarURL, action: imageAPI.action)
                }
                return images
            }
            .asDriver(onErrorJustReturn: [:])
        
        let errorSignal = Observable.merge(searchAction.errors, selectUserAction.errors)
            .map({ (actionError) -> Error in
                switch actionError.underlying {
                case let error as Error:
                    return error
                default:
                    return .unhandledError
                }
            })
            .asSignal(onErrorSignalWith: .empty())
        
        selectUserAction.elements
            .withLatestFrom(selectUserAction.inputs, resultSelector: { ($1, $0) })
            .subscribe(onNext: { (user, repositories) in
                router.trigger(.userProfile(user: user, repositories: repositories))
            })
            .disposed(by: self.disposeBag)
        
        self.input = Input(
            search: searchAction.inputs,
            getMoreUsers: getNextUsersPageAction.inputs,
            selectUser: selectUserAction.inputs
        )
        
        self.output = Output(
            isSearchingUsers: isSearchingUsersDriver,
            isGettingMoreUsers: isGettingMoreUsersDriver,
            users: usersDriver,
            isSearchingRepositories: isSearchingRepositoriesDriver,
            avatars: imagesDriver,
            error: errorSignal
        )
    }
    
    // MARK: - ViewModelType
    
    public var input: Input
    public var output: Output
    
    public struct Input {
        public var search: InputSubject<String?>
        public var getMoreUsers: InputSubject<Void>
        public var selectUser: InputSubject<User>
    }
    
    public struct Output {
        public var isSearchingUsers: Driver<Bool>
        public var isGettingMoreUsers: Driver<Bool>
        public var users: Driver<[User]>
        public var isSearchingRepositories: Driver<Bool>
        public var avatars: Driver<[URL: RxImage]>
        public var error: Signal<Error>
        
        public var isSearching: Driver<Bool> {
            return Driver<Bool>.combineLatest(
                self.isSearchingUsers,
                self.isSearchingRepositories,
                resultSelector: { $0 || $1 }
            )
        }
        
        private func rxImage(for url: URL) -> Driver<RxImage> {
            return self.avatars
                .map({ $0[url] })
                .filterNil()
        }
        
        public func avatar(for url: URL) -> Driver<UIImage> {
            return self.rxImage(for: url)
                .flatMap({ $0.resource.asDriver(onErrorDriveWith: .empty()) })
        }
        
        public func avatar(for user: User) -> Driver<UIImage> {
            guard let avatarURL = user.avatarURL else { return .empty() }
            return self.avatar(for: avatarURL)
        }
        
        public func prefetchAvatar(for url: URL) -> Disposable {
            return self.rxImage(for: url)
                .drive(onNext: { $0.prefetch() })
        }
        
        public func prefetchAvatar(for user: User) -> Disposable? {
            guard let avatarURL = user.avatarURL else { return nil }
            return self.prefetchAvatar(for: avatarURL)
        }
        
        public func isGettingImage(with url: URL)  -> Driver<Bool> {
            return self.avatars.map({ $0[url]?.isGettingResource ?? .just(false) })
                .flatMap({ $0.asDriver(onErrorJustReturn: false) })
        }
        
        public func isGettingImage(for user: User) -> Driver<Bool> {
            guard let avatarURL = user.avatarURL else { return .just(false) }
            return self.isGettingImage(with: avatarURL)
        }
        
    }
    
    // MARK: -
    
    public enum Error: Swift.Error, Equatable {
        case loginNotFound
        case unhandledError
    }
    
}
