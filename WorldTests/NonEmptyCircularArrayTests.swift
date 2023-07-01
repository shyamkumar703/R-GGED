//
//  NonEmptyCircularArrayTests.swift
//  WorldTests
//
//  Created by Shyam Kumar on 6/30/23.
//

@testable import World
import XCTest

final class NonEmptyCircularArrayTests: XCTestCase {
    func testOneElement_ReturnsSameFirstValueEveryTime() {
        var sut = NonEmptyCircularArray(1)
        XCTAssertEqual(sut.getFirst(), 1)
        XCTAssertEqual(sut.getFirst(), 1)
        XCTAssertEqual(sut.getFirst(), 1)
    }
    
    func testTwoElements_CyclesBetweenBothElements() {
        var sut = NonEmptyCircularArray(1, 2)
        XCTAssertEqual(sut.getFirst(), 1)
        XCTAssertEqual(sut.toArray(), [2, 1])
        XCTAssertEqual(sut.getFirst(), 2)
        XCTAssertEqual(sut.toArray(), [1, 2])
        XCTAssertEqual(sut.getFirst(), 1)
    }
}
