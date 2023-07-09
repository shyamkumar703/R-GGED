//
//  UmpireGameTests.swift
//  WorldTests
//
//  Created by Shyam Kumar on 7/7/23.
//

@testable import World
import XCTest

final class UmpireGameTests: XCTestCase {
    func testUmpireGame_StartsAtOneHundred() {
        let sut = Game.mockWithUmpireGame.optionalUmpireGame
        XCTAssertEqual(sut.umpireGame?.homeTeamGrade, 100)
        XCTAssertEqual(sut.umpireGame?.awayTeamGrade, 100)
        XCTAssertEqual(sut.umpireGame?.grade, 100)
    }
    
    func testMakingWrongCall_DecreasesUmpireGrade() {
        var sut: Game = .mockWithUmpireGame {
            .init(x: -0.6, y: -11)
        }
        guard case .call(let pitch) = sut.generatePitch() else {
            XCTFail()
            return
        }
        sut.makeCall(call: .strike, on: pitch)
        XCTAssertEqual(sut.optionalUmpireGame.umpireGame?.awayTeamGrade, 90)
        XCTAssertEqual(sut.optionalUmpireGame.umpireGame?.grade, 95)
    }
    
    func testMakingRightCall_IncreasesUmpireGrade() {
        var sut: Game = .mockWithUmpireGame {
            .init(x: -0.6, y: -11)
        }
        guard case .call(let pitch) = sut.generatePitch() else {
            XCTFail()
            return
        }
        sut.makeCall(call: .strike, on: pitch)
        XCTAssertEqual(sut.optionalUmpireGame.umpireGame?.awayTeamGrade, 90)
        XCTAssertEqual(sut.optionalUmpireGame.umpireGame?.grade, 95)
        guard case .call(let pitch) = sut.generatePitch() else {
            XCTFail()
            return
        }
        sut.makeCall(call: .ball, on: pitch)
        XCTAssertEqual(sut.optionalUmpireGame.umpireGame?.awayTeamGrade, 92)
        XCTAssertEqual(sut.optionalUmpireGame.umpireGame?.grade, 96)
    }
    
    func testMakingRightCall_WithMaxGrades_KeepsUmpireGradeTheSame() {
        var sut: Game = .mockWithUmpireGame {
            .init(x: -0.6, y: -11)
        }
        guard case .call(let pitch) = sut.generatePitch() else {
            XCTFail()
            return
        }
        sut.makeCall(call: .ball, on: pitch)
        XCTAssertEqual(sut.optionalUmpireGame.umpireGame?.awayTeamGrade, 100)
        XCTAssertEqual(sut.optionalUmpireGame.umpireGame?.grade, 100)
    }
}
