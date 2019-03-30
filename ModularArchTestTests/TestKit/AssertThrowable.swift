//
//  AssertThrowable.swift
//  ModularArchTestTestsTests
//
//  Created by Gustavo Vergara Garcia on 27/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import Foundation
import Nimble
import Quick

func assertThrowableReturnsOptional<Return>(expression: @autoclosure @escaping () throws -> Return) -> Return? {
    expect(expression).toNot(throwError())
    return try? expression()
}

func assertThrowable<Return>(expression: @autoclosure @escaping () throws -> Return) -> Return {
    let returnValue = assertThrowableReturnsOptional(expression: expression)
    expect(returnValue).toNot(beNil())
    return returnValue!
}
