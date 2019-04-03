//
//  UserSearchViewModelTests.swift
//  ModularArchTestTestsTests
//
//  Created by Gustavo Vergara Garcia on 25/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import XCTest
import Nimble
import RxSwift
import RxCocoa
import RxNimbleRxTest
import RxNimbleRxBlocking
import RxTest
import XCoordinator
import Moya
import MATKit
@testable import MATUI

class UserSearchViewModelTests: XCTestCase {
    
    let coordinator = TestAppCoordinator()
    
    let successfulGitHubProvider = MoyaProvider<GitHubTarget>(
        stubClosure: MoyaProvider.immediatelyStub
    )
    
    let notFoundGitHubProvider = MoyaProvider<GitHubTarget>(
        endpointClosure: { (target) -> Endpoint in
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: { .networkResponse(404, GitHubMocks.notFound) },
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        },
        stubClosure: MoyaProvider.immediatelyStub
    )
    
    let internalServerErrorGitHubProvider = MoyaProvider<GitHubTarget>(
        endpointClosure: { (target) -> Endpoint in
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: { .networkResponse(500, Data()) },
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        },
        stubClosure: MoyaProvider.immediatelyStub
    )
    
    let emptySuccessErrorGitHubProvider = MoyaProvider<GitHubTarget>(
        endpointClosure: { (target) -> Endpoint in
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: { .networkResponse(200, Data()) },
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        },
        stubClosure: MoyaProvider.immediatelyStub
    )
    
    let emptyArrayGitHubProvider = MoyaProvider<GitHubTarget>(
        endpointClosure: { (target) -> Endpoint in
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: { .networkResponse(200, "[]".data(using: .utf8)!) },
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        },
        stubClosure: MoyaProvider.immediatelyStub
    )
    
    let jsonDecoder = JSONDecoder(dateDecodingStrategy: .iso8601(formatOptions: .withInternetDateTime))
    
    lazy var githubAPI = GitHubAPI(gitHubProvider: self.successfulGitHubProvider)

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInitialState() {
        let viewModel = UserSearchViewModel(router: self.coordinator.anyRouter, gitHubAPI: self.githubAPI)
        expect(viewModel.output.isSearching.asObservable()).first == false
    }

    func testIsSearching_Success() {
        let testScheduler = TestScheduler(initialClock: 0)
        
        let viewModel = UserSearchViewModel(router: self.coordinator.anyRouter, gitHubAPI: GitHubAPI(gitHubProvider: self.successfulGitHubProvider))
        let disposeBag = DisposeBag()
        
        let searchEvents = [Recorded.next(1, "GustavoVergara")]
        let searchEventsObservable = testScheduler.createHotObservable(searchEvents)
        
        let expectedIsSearchingEvents = [Recorded.next(0, false), Recorded.next(1, true), Recorded.next(1, false)]
        
        searchEventsObservable.bind(to: viewModel.input.search).disposed(by: disposeBag)
        
        let recordedIsSearching = testScheduler.start(created: 0, subscribed: 0, sequence: viewModel.output.isSearching)

        expect(recordedIsSearching.events).to(equal(expectedIsSearchingEvents))
    }
    
    func testIsSearching_NotFound() {
        let testScheduler = TestScheduler(initialClock: 0)
        
        let viewModel = UserSearchViewModel(router: self.coordinator.anyRouter, gitHubAPI: GitHubAPI(gitHubProvider: self.notFoundGitHubProvider))
        let disposeBag = DisposeBag()
        
        let searchEvents = [Recorded.next(1, "GustavoVergara")]
        let searchEventsObservable = testScheduler.createHotObservable(searchEvents)
        
        let expectedIsSearchingEvents = [Recorded.next(0, false), Recorded.next(1, true), Recorded.next(1, false)]
        
        searchEventsObservable.bind(to: viewModel.input.search).disposed(by: disposeBag)
        
        let recordedIsSearching = testScheduler.start(created: 0, subscribed: 0, sequence: viewModel.output.isSearching)
        
        expect(recordedIsSearching.events).to(equal(expectedIsSearchingEvents))
    }
    
    func testRedirect_Success() {
        let testScheduler = TestScheduler(initialClock: 0)
        
        let viewModel = UserSearchViewModel(router: self.coordinator.anyRouter, gitHubAPI: GitHubAPI(gitHubProvider: self.successfulGitHubProvider))
        let disposeBag = DisposeBag()
        
        let repositories = assertThrowable(expression: try self.jsonDecoder.decode([Repository].self, from: GitHubMocks.getRepositories()))
        let owner = repositories.first?.owner
        expect(owner).toNot(beNil())
        
        let searchEvents = [Recorded.next(1, "GustavoVergara")]
        let searchEventsObservable = testScheduler.createHotObservable(searchEvents)
        
        let expectedRouteTriggers = [Recorded.next(1, AppRoute.userProfile(user: owner!, repositories: repositories))]
        
        searchEventsObservable.bind(to: viewModel.input.search).disposed(by: disposeBag)
        
        let routeTriggerObservable = self.coordinator.rx.onTrigger()
        let recordedRouteTriggers = testScheduler.start(created: 0, subscribed: 0, sequence: routeTriggerObservable)
        
        expect(recordedRouteTriggers.events).to(equal(expectedRouteTriggers))
    }
    
    func testRedirect_UserNotFound() {
        let testScheduler = TestScheduler(initialClock: 0)
        
        let viewModel = UserSearchViewModel(router: self.coordinator.anyRouter, gitHubAPI: GitHubAPI(gitHubProvider: self.notFoundGitHubProvider))
        let disposeBag = DisposeBag()
        
        let searchEvents = [Recorded.next(1, "GustavoVergara")]
        let searchEventsObservable = testScheduler.createHotObservable(searchEvents)
        
        let expectedErrors = [Recorded.next(1, UserSearchViewModel.Error.usernameNotFound)]
        
        searchEventsObservable.bind(to: viewModel.input.search).disposed(by: disposeBag)
        
        let recordedErrors = testScheduler.start(created: 0, subscribed: 0, sequence: viewModel.output.error)
        
        expect(recordedErrors.events).to(equal(expectedErrors))
    }
    
    func testRedirect_UsernameEmpty() {
        let testScheduler = TestScheduler(initialClock: 0)
        
        let viewModel = UserSearchViewModel(router: self.coordinator.anyRouter, gitHubAPI: GitHubAPI(gitHubProvider: self.successfulGitHubProvider))
        let disposeBag = DisposeBag()
        
        let searchEvents = [Recorded.next(1, "")]
        let searchEventsObservable = testScheduler.createHotObservable(searchEvents)
        
        let expectedErrors = [Recorded.next(1, UserSearchViewModel.Error.usernameIsEmpty)]
        
        searchEventsObservable.bind(to: viewModel.input.search).disposed(by: disposeBag)
        
        let recordedErrors = testScheduler.start(created: 0, subscribed: 0, sequence: viewModel.output.error)
        
        expect(recordedErrors.events).to(equal(expectedErrors))
    }
    
    func testRedirect_UsernameNil() {
        let testScheduler = TestScheduler(initialClock: 0)
        
        let viewModel = UserSearchViewModel(router: self.coordinator.anyRouter, gitHubAPI: GitHubAPI(gitHubProvider: self.successfulGitHubProvider))
        let disposeBag = DisposeBag()
        
        let searchEvents = [Recorded.next(1, String?.none)]
        let searchEventsObservable = testScheduler.createHotObservable(searchEvents)
        
        let expectedErrors = [Recorded.next(1, UserSearchViewModel.Error.usernameIsEmpty)]
        
        searchEventsObservable.bind(to: viewModel.input.search).disposed(by: disposeBag)
        
        let recordedErrors = testScheduler.start(created: 0, subscribed: 0, sequence: viewModel.output.error)
        
        expect(recordedErrors.events).to(equal(expectedErrors))
    }
    
    func testRedirect_InternalServerError() {
        let testScheduler = TestScheduler(initialClock: 0)
        
        let viewModel = UserSearchViewModel(router: self.coordinator.anyRouter, gitHubAPI: GitHubAPI(gitHubProvider: self.internalServerErrorGitHubProvider))
        let disposeBag = DisposeBag()
        
        let searchEvents = [Recorded.next(1, "GustavoVergara")]
        let searchEventsObservable = testScheduler.createHotObservable(searchEvents)
        
        let expectedErrors = [Recorded.next(1, UserSearchViewModel.Error.unhandledError)]
        
        searchEventsObservable.bind(to: viewModel.input.search).disposed(by: disposeBag)
        
        let recordedErrors = testScheduler.start(created: 0, subscribed: 0, sequence: viewModel.output.error)
        
        expect(recordedErrors.events).to(equal(expectedErrors))
    }
    
    func testRedirect_EmptyData() {
        let testScheduler = TestScheduler(initialClock: 0)
        
        let viewModel = UserSearchViewModel(router: self.coordinator.anyRouter, gitHubAPI: GitHubAPI(gitHubProvider: self.emptySuccessErrorGitHubProvider))
        let disposeBag = DisposeBag()
        
        let searchEvents = [Recorded.next(1, "GustavoVergara")]
        let searchEventsObservable = testScheduler.createHotObservable(searchEvents)
        
        let expectedErrors = [Recorded.next(1, UserSearchViewModel.Error.unhandledError)]
        
        searchEventsObservable.bind(to: viewModel.input.search).disposed(by: disposeBag)
        
        let recordedErrors = testScheduler.start(created: 0, subscribed: 0, sequence: viewModel.output.error)
        
        expect(recordedErrors.events).to(equal(expectedErrors))
    }
    
    func testRedirect_UserDoesNotHaveAnyRepository() {
        let testScheduler = TestScheduler(initialClock: 0)
        
        let viewModel = UserSearchViewModel(router: self.coordinator.anyRouter, gitHubAPI: GitHubAPI(gitHubProvider: self.emptyArrayGitHubProvider))
        let disposeBag = DisposeBag()
        
        let searchEvents = [Recorded.next(1, "GustavoVergara")]
        let searchEventsObservable = testScheduler.createHotObservable(searchEvents)
        
        let expectedErrors = [Recorded.next(1, UserSearchViewModel.Error.userDoesNotHaveAnyRepository)]
        
        searchEventsObservable.bind(to: viewModel.input.search).disposed(by: disposeBag)
        
        let recordedErrors = testScheduler.start(created: 0, subscribed: 0, sequence: viewModel.output.error)
        
        expect(recordedErrors.events).to(equal(expectedErrors))
    }

}
