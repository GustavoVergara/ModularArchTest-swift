//
//  UserProfileViewModelTests.swift
//  ModularArchTestTestsTests
//
//  Created by Gustavo Vergara Garcia on 28/02/19.
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
import MATKit
@testable import MATUI

class UserProfileViewModelTests: XCTestCase {

    let coordinator = TestAppCoordinator()
    
    let jsonDecoder = JSONDecoder(dateDecodingStrategy: .iso8601(formatOptions: .withInternetDateTime))
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUser() {
        let testScheduler = TestScheduler(initialClock: 0)
        
        let repositories = assertThrowable(expression: try self.jsonDecoder.decode([Repository].self, from: GitHubMocks.getRepositories()))
        let user = repositories.first!.owner
        
        let viewModel = UserProfileViewModel(user: user, repositories: repositories, router: self.coordinator.anyRouter)

        let testableUser = testScheduler.start(sequence: viewModel.output.user)
        
        expect(testableUser.events.first?.value.element) == user
    }
    
    func testUsername() {
        let testScheduler = TestScheduler(initialClock: 0)
        
        let repositories = assertThrowable(expression: try self.jsonDecoder.decode([Repository].self, from: GitHubMocks.getRepositories()))
        let user = repositories.first!.owner
        
        let viewModel = UserProfileViewModel(user: user, repositories: repositories, router: self.coordinator.anyRouter)
        
        let testableUsername = testScheduler.start(sequence: viewModel.output.username)

        expect(testableUsername.events.first?.value.element) == user.login
    }
    
    func testRepositories() {
        let testScheduler = TestScheduler(initialClock: 0)
        
        let repositories = assertThrowable(expression: try self.jsonDecoder.decode([Repository].self, from: GitHubMocks.getRepositories()))
        let user = repositories.first!.owner
        
        let viewModel = UserProfileViewModel(user: user, repositories: repositories, router: self.coordinator.anyRouter)
        
        let testableProfileImage = testScheduler.start(sequence: viewModel.output.repositories)
        
        expect(testableProfileImage.events.first?.value.element) == repositories
    }
    
    func testRedirect() {
        let testScheduler = TestScheduler(initialClock: 0)
        let disposeBag = DisposeBag()

        let repositories = assertThrowable(expression: try self.jsonDecoder.decode([Repository].self, from: GitHubMocks.getRepositories()))
        let user = repositories.first!.owner
        
        let viewModel = UserProfileViewModel(user: user, repositories: repositories, router: self.coordinator.anyRouter)
        
        let selectRepositoryEvents = [Recorded.next(1, repositories.first!)]
        let selectRepositoryEventsObservable = testScheduler.createHotObservable(selectRepositoryEvents)
        
        let expectedRouteTriggers = [Recorded.next(1, AppRoute.repoDetail(repositories.first!))]
        
        selectRepositoryEventsObservable.bind(to: viewModel.input.selectRepository).disposed(by: disposeBag)
        
        let routeTriggerObservable = self.coordinator.rx.onTrigger()
        let recordedRouteTriggers = testScheduler.start(created: 0, subscribed: 0, sequence: routeTriggerObservable)
        
        expect(recordedRouteTriggers.events).to(equal(expectedRouteTriggers))
    }

}
