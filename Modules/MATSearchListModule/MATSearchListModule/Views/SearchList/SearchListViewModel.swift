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
    
    //    private var actions: [ActionType] = []
    
    private let disposeBag = DisposeBag()
    
    public init(router: AnyRouter<AppRoute>, gitHubAPI: GitHubAPI = GitHubAPI(), imageAPI: ImageAPI = ImageAPI()) {
        let searchAction = Action<String?, [User]>(workFactory: { (login) in
//            guard let login = login, login.isEmpty == false else {
//                return .error(Error.loginIsEmpty)
//            }
            
            return gitHubAPI.searchUsers(login: login ?? "")
                .map({ $0.items })
                .asObservable()
        })
        Disposables.createStrongReferenceTo(searchAction).disposed(by: self.disposeBag)
        
        let isSearchingUsersDriver = searchAction.executing.asDriver(onErrorJustReturn: false)
        
        let selectUserAction = Action<User, [Repository]>(workFactory: { (user) -> Observable<[Repository]> in
            return gitHubAPI.getRepositories(ownerUsername: user.login)
                .flatMap({ (repositories) -> Single<[Repository]> in
                    guard repositories.isEmpty == false else {
                        return .error(Error.userDoesNotHaveAnyRepository)
                    }
                    return .just(repositories)
                })
                .asObservable()
        })
        Disposables.createStrongReferenceTo(selectUserAction).disposed(by: self.disposeBag)
        
        let isSearchingRepositoriesDriver = selectUserAction.executing.asDriver(onErrorJustReturn: false)
        
        let imagesDriver = searchAction.elements
            .map { (users) -> [URL: RxImage] in
                var images = [URL: RxImage]()
                for user in users {
                    guard let avatarURL = user.avatarURL else { continue }
                    images[avatarURL] = RxImage(url: avatarURL, action: imageAPI.action)
                }
                return images
            }
            .asDriver(onErrorJustReturn: [:])
        
        let errorSignal = searchAction.errors
            .map({ (actionError) -> Error in
                switch actionError.underlying {
                case let error as Error:
                    return error
                case let error as MoyaError:
                    switch error {
                    case .statusCode(let response) where response.statusCode == 404:
                        return .loginNotFound
                    default: break
                    }
                default: break
                }
                // default
                return .unhandledError
            })
            .asSignal(onErrorSignalWith: .empty())
        
        selectUserAction.elements
            .subscribe(onNext: { (repositories) in
                guard let owner = repositories.first?.owner else { return }
                router.trigger(.userProfile(user: owner, repositories: repositories))
            })
            .disposed(by: self.disposeBag)
        
        self.input = Input(
            search: searchAction.inputs,
            selectUser: selectUserAction.inputs
        )
        
        self.output = Output(
            isSearchingUsers: isSearchingUsersDriver,
            users: searchAction.elements.asDriver(onErrorJustReturn: []),
            isSearchingRepositories: isSearchingRepositoriesDriver,
            images: imagesDriver,
            error: errorSignal
        )
    }
    
    // MARK: - ViewModelType
    
    public var input: Input
    public var output: Output
    
    public struct Input {
        public var search: InputSubject<String?>
        public var selectUser: InputSubject<User>
    }
    
    public struct Output {
        public var isSearchingUsers: Driver<Bool>
        public var users: Driver<[User]>
        public var isSearchingRepositories: Driver<Bool>
        public var images: Driver<[URL: RxImage]>
        public var error: Signal<Error>
        
        public var isSearching: Driver<Bool> {
            return Driver<Bool>.combineLatest(
                self.isSearchingUsers,
                self.isSearchingRepositories,
                resultSelector: { $0 || $1 }
            )
        }
        
        public func avatarURL(for user: User) -> Driver<UIImage> {
            guard let avatarURL = user.avatarURL else { return .empty() }
            return self.image(for: avatarURL)
        }
        
        public func isGettingImage(for user: User) -> Driver<Bool> {
            guard let avatarURL = user.avatarURL else { return .just(false) }
            return self.isGettingImage(with: avatarURL)
        }
        
        public func image(for url: URL) -> Driver<UIImage> {
            return self.images.flatMap({
                $0[url]?.image.asDriver(onErrorDriveWith: .empty()) ?? .empty()
            })
        }
        
        public func isGettingImage(with url: URL)  -> Driver<Bool> {
            return self.images.flatMap({
                $0[url]?.isGettingImage.asDriver(onErrorJustReturn: false) ?? Driver.just(false)
            })
        }
    }
    
    // MARK: -
    
    public enum Error: Swift.Error, Equatable {
        case loginIsEmpty
        case loginNotFound
        case unhandledError
        case userDoesNotHaveAnyRepository
    }
    
}

public struct RxImage {
    let image: Observable<UIImage>
    let isGettingImage: Observable<Bool>
    
    private let disposeBag = DisposeBag()
    
    init(image: UIImage) {
        self.image = Observable.just(image)
        self.isGettingImage = Observable.just(false)
    }
    
    init(imageObservable: Observable<UIImage>, isGettingImage: Observable<Bool>) {
        self.image = imageObservable
        self.isGettingImage = isGettingImage
    }
    
    init(url: URL, action: Action<URL, UIImage>) {
        self.image = Observable.deferred({ action.execute(url) }).share(replay: 1, scope: .forever)
        self.isGettingImage = action.executing
        Disposables.createStrongReferenceTo(action).disposed(by: self.disposeBag)
    }
}
