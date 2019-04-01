//
//  RepositoryDetailViewModelTests.swift
//  ModularArchTestTestsTests
//
//  Created by Gustavo Vergara Garcia on 01/03/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxNimbleRxTest
import RxNimbleRxBlocking
import RxTest
import Nimble
import XCoordinator
import Moya
@testable import MATUI

class RepositoryDetailViewModelTests: XCTestCase {

    let coordinator = TestAppCoordinator()
    
    let jsonDecoder = JSONDecoder(dateDecodingStrategy: .iso8601(formatOptions: .withInternetDateTime))
    
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
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testRepository() {
        let testScheduler = TestScheduler(initialClock: 0)
        
        let repositories = assertThrowable(expression: try self.jsonDecoder.decode([Repository].self, from: GitHubMocks.getRepositories()))
        let firstRepository = repositories.first!
        
        let viewModel = RepositoryDetailViewModel(repository: firstRepository, router: self.coordinator.anyRouter, gitHubAPI: GitHubAPI(gitHubProvider: self.successfulGitHubProvider))
        
        let testableRepository = testScheduler.start(sequence: viewModel.output.repository)
        
        expect(testableRepository.events.first?.value.element) == firstRepository
    }
    
    func testCanOpenOnGitHub() {
        let testScheduler = TestScheduler(initialClock: 0)
        
        let repositories = assertThrowable(expression: try self.jsonDecoder.decode([Repository].self, from: GitHubMocks.getRepositories()))
        var firstRepository = repositories.first!
        firstRepository.htmlURL = URL(string: "https://github.com/quickbirdstudios/XCoordinator")!
        
        let viewModel = RepositoryDetailViewModel(repository: firstRepository, router: self.coordinator.anyRouter, gitHubAPI: GitHubAPI(gitHubProvider: self.successfulGitHubProvider))

        let testableCanOpenOnGitHub = testScheduler.start(sequence: viewModel.output.canOpenOnGitHub)
        
        expect(testableCanOpenOnGitHub.events.first?.value.element) == true
    }
    
    func testCanNotOpenOnGitHub() {
        let testScheduler = TestScheduler(initialClock: 0)
        
        let repositories = assertThrowable(expression: try self.jsonDecoder.decode([Repository].self, from: GitHubMocks.getRepositories()))
        var firstRepository = repositories.first!
        firstRepository.htmlURL = nil
        
        let viewModel = RepositoryDetailViewModel(repository: firstRepository, router: self.coordinator.anyRouter, gitHubAPI: GitHubAPI(gitHubProvider: self.successfulGitHubProvider))
        
        let testableCanOpenOnGitHub = testScheduler.start(sequence: viewModel.output.canOpenOnGitHub)
        
        expect(testableCanOpenOnGitHub.events.first?.value.element) == false
    }
    
    func testIsGettingIssues() {
        let testScheduler = TestScheduler(initialClock: 0)
        let disposeBag = DisposeBag()

        let repositories = assertThrowable(expression: try self.jsonDecoder.decode([Repository].self, from: GitHubMocks.getRepositories()))
        let firstRepository = repositories.first!
        
        let viewModel = RepositoryDetailViewModel(repository: firstRepository, router: self.coordinator.anyRouter, gitHubAPI: GitHubAPI(gitHubProvider: self.successfulGitHubProvider))
        
        let expectedEvents = [Recorded.next(0, false), Recorded.next(1, true), Recorded.next(1, false)]
        
        testScheduler.schedule(1, action: { _ in viewModel.output.totalIssuesCount.drive() })
            .disposed(by: disposeBag)
        let recordedObservable = testScheduler.start(created: 0, subscribed: 0, sequence: viewModel.output.isGettingIssues)
        
        expect(recordedObservable.events).to(equal(expectedEvents))
    }
    
    func testTotalIssuesCount() {
        let testScheduler = TestScheduler(initialClock: 0)
        
        let repositories = assertThrowable(expression: try self.jsonDecoder.decode([Repository].self, from: GitHubMocks.getRepositories()))
        let firstRepository = repositories.first!
        
        let issuesResult = assertThrowable(expression: try self.jsonDecoder.decode(SearchResult<Issue>.self, from: GitHubMocks.searchIssues()))
        
        let viewModel = RepositoryDetailViewModel(repository: firstRepository, router: self.coordinator.anyRouter, gitHubAPI: GitHubAPI(gitHubProvider: self.successfulGitHubProvider))
        
        let expectedEvents: [Recorded<Event<Int?>>] = [Recorded.next(0, nil), Recorded.next(0, issuesResult.totalCount)]
        
        let recordedObservable = testScheduler.start(created: 0, subscribed: 0, sequence: viewModel.output.totalIssuesCount)
        
        expect(recordedObservable.events).to(equal(expectedEvents))
    }
    
    func testRedirect() {
        let testScheduler = TestScheduler(initialClock: 0)
        let disposeBag = DisposeBag()
        
        let repositories = assertThrowable(expression: try self.jsonDecoder.decode([Repository].self, from: GitHubMocks.getRepositories()))
        var firstRepository = repositories.first!
        let htmlURL = URL(string: "https://github.com/quickbirdstudios/XCoordinator")!
        firstRepository.htmlURL = htmlURL

        
        let viewModel = RepositoryDetailViewModel(repository: firstRepository, router: self.coordinator.anyRouter, gitHubAPI: GitHubAPI(gitHubProvider: self.successfulGitHubProvider))

        let openOnGitHubEvents = [Recorded.next(1, ())]
        let openOnGitHubEventsObservable = testScheduler.createHotObservable(openOnGitHubEvents)
        
        let expectedEvents = [Recorded.next(1, AppRoute.externalURL(htmlURL))]
        
        openOnGitHubEventsObservable.bind(to: viewModel.input.openOnGitHub).disposed(by: disposeBag)
        
        let routeTriggerObservable = self.coordinator.rx.onTrigger()
        let recordedRouteTriggers = testScheduler.start(created: 0, subscribed: 0, sequence: routeTriggerObservable)
        
        expect(recordedRouteTriggers.events).to(equal(expectedEvents))
    }

}
