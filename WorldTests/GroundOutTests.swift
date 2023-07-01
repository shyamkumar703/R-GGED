//
//  GroundOutTests.swift
//  WorldTests
//
//  Created by Shyam Kumar on 7/1/23.
//

@testable import World
import XCTest

final class GroundOutTests: XCTestCase {
    func testGroundOut_BasesEmpty_ResultsInAnOut() {
        var sut: Game = .mockWith() { _, _ in .groundOut }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .groundOut else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.outs, 1)
    }
    
    func testGroundOut_BasesLoadedOneOut_InningOver() {
        var sut: Game = .mockWith(
            first: .init(
                playerOn: .empty,
                pitcherResponsible: .empty
            ),
            second: .init(
                playerOn: .empty,
                pitcherResponsible: .empty
            ),
            third: .init(
                playerOn: .empty,
                pitcherResponsible: .empty
            ),
            batter: .empty,
            pitcher: .empty,
            outs: 1
        ) { _, _ in .groundOut }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .groundOut else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.awayTeamScore, 0)
        XCTAssertEqual(sut.outs, 0) // inning over
        XCTAssertEqual(sut.halfInning, .bottom)
        XCTAssertEqual(sut.inning, 1)
    }
    
    func testGroundOut_BasesLoadedZeroOuts_OneRunScoresAndTwoOutsRecorded() {
        let runner = Player.empty()
        var sut: Game = .mockWith(
            first: .init(
                playerOn: .empty,
                pitcherResponsible: .empty
            ),
            second: .init(
                playerOn: runner,
                pitcherResponsible: .empty
            ),
            third: .init(
                playerOn: .empty,
                pitcherResponsible: .empty
            ),
            batter: .empty,
            pitcher: .empty
        ) { _, _ in .groundOut }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .groundOut else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.awayTeamScore, 1)
        XCTAssertEqual(sut.outs, 2)
        XCTAssertEqual(sut.thirdBase.playerOn, runner)
        XCTAssertEqual(sut.secondBase, .empty)
        XCTAssertEqual(sut.firstBase, .empty)
    }
    
    func testGroundOut_FirstAndSecondZeroOut_TwoOutsAndRunnerToThird() {
        let runner = Player.empty()
        var sut: Game = .mockWith(
            first: .init(
                playerOn: .empty,
                pitcherResponsible: .empty
            ),
            second: .init(
                playerOn: runner,
                pitcherResponsible: .empty
            ),
            batter: .empty,
            pitcher: .empty
        ) { _, _ in .groundOut }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .groundOut else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.awayTeamScore, 0)
        XCTAssertEqual(sut.outs, 2)
        XCTAssertEqual(sut.thirdBase.playerOn, runner)
        XCTAssertEqual(sut.secondBase, .empty)
        XCTAssertEqual(sut.firstBase, .empty)
    }
    
    func testGroundOut_FirstAndSecondOneOut_InningOver() {
        let runner = Player.empty()
        var sut: Game = .mockWith(
            first: .init(
                playerOn: .empty,
                pitcherResponsible: .empty
            ),
            second: .init(
                playerOn: runner,
                pitcherResponsible: .empty
            ),
            batter: .empty,
            pitcher: .empty,
            outs: 1
        ) { _, _ in .groundOut }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .groundOut else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.awayTeamScore, 0)
        XCTAssertEqual(sut.outs, 0) // inning over
        XCTAssertEqual(sut.halfInning, .bottom)
        XCTAssertEqual(sut.inning, 1)
    }
    
    func testGroundOut_FirstAndThirdZeroOut_TwoOutsAndRunnerScores() {
        var sut: Game = .mockWith(
            first: .init(
                playerOn: .empty,
                pitcherResponsible: .empty
            ),
            third: .init(
                playerOn: .empty,
                pitcherResponsible: .empty
            ),
            batter: .empty,
            pitcher: .empty
        ) { _, _ in .groundOut }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .groundOut else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.outs, 2) // inning over
        XCTAssertEqual(sut.awayTeamScore, 1)
    }
    
    func testGroundOut_FirstAndThirdOneOut_InningOver() {
        var sut: Game = .mockWith(
            first: .init(
                playerOn: .empty,
                pitcherResponsible: .empty
            ),
            third: .init(
                playerOn: .empty,
                pitcherResponsible: .empty
            ),
            batter: .empty,
            pitcher: .empty,
            outs: 1
        ) { _, _ in .groundOut }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .groundOut else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.awayTeamScore, 0)
        XCTAssertEqual(sut.outs, 0) // inning over
        XCTAssertEqual(sut.halfInning, .bottom)
        XCTAssertEqual(sut.inning, 1)
    }
    
    func testGroundOut_SecondAndThirdNoOuts_OneOutAndRunnerOnThirdAndRunScores() {
        let runner = Player.empty()
        
        var sut: Game = .mockWith(
            second: .init(
                playerOn: runner,
                pitcherResponsible: .empty
            ),
            third: .init(
                playerOn: .empty,
                pitcherResponsible: .empty
            ),
            batter: .empty,
            pitcher: .empty
        ) { _, _ in .groundOut }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .groundOut else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.awayTeamScore, 1)
        XCTAssertEqual(sut.thirdBase.playerOn, runner)
        XCTAssertEqual(sut.secondBase, .empty)
        XCTAssertEqual(sut.firstBase, .empty)
        XCTAssertEqual(sut.outs, 1)
    }
    
    func testGroundOut_SecondAndThirdOneOut_TwoOutsAndRunnerOnThirdScores() {
        let runner = Player.empty()
        
        var sut: Game = .mockWith(
            second: .init(
                playerOn: runner,
                pitcherResponsible: .empty
            ),
            third: .init(
                playerOn: .empty,
                pitcherResponsible: .empty
            ),
            batter: .empty,
            pitcher: .empty,
            outs: 1
        ) { _, _ in .groundOut }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .groundOut else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.awayTeamScore, 1)
        XCTAssertEqual(sut.thirdBase.playerOn, runner)
        XCTAssertEqual(sut.secondBase, .empty)
        XCTAssertEqual(sut.firstBase, .empty)
        XCTAssertEqual(sut.outs, 2)
    }
    
    func testGroundOut_SecondAndThirdTwoOuts_InningOver() {
        let runner = Player.empty()
        
        var sut: Game = .mockWith(
            second: .init(
                playerOn: runner,
                pitcherResponsible: .empty
            ),
            third: .init(
                playerOn: .empty,
                pitcherResponsible: .empty
            ),
            batter: .empty,
            pitcher: .empty,
            outs: 2
        ) { _, _ in .groundOut }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .groundOut else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.awayTeamScore, 0)
        XCTAssertEqual(sut.outs, 0) // inning over
        XCTAssertEqual(sut.halfInning, .bottom)
        XCTAssertEqual(sut.inning, 1)
    }
    
    func testGroundOut_RunnerOnFirst_ResultsInDoublePlay() {
        var sut: Game = .mockWith(
            first: .init(
                playerOn: .empty,
                pitcherResponsible: .empty
            )
        ) { _, _ in .groundOut }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .groundOut else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.outs, 2)
    }
    
    func testGroundOut_RunnerOnFirstOneOut_InningOver() {
        var sut: Game = .mockWith(
            first: .init(
                playerOn: .empty,
                pitcherResponsible: .empty
            ),
            outs: 1
        ) { _, _ in .groundOut }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .groundOut else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.awayTeamScore, 0)
        XCTAssertEqual(sut.outs, 0) // inning over
        XCTAssertEqual(sut.halfInning, .bottom)
        XCTAssertEqual(sut.inning, 1)
    }
    
    func testGroundOut_RunnerOnSecondNoOuts_OneOutAndRunnerToThird() {
        let runner = Player.empty()
        var sut: Game = .mockWith(
            second: .init(
                playerOn: runner,
                pitcherResponsible: .empty
            )
        ) { _, _ in .groundOut }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .groundOut else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.outs, 1)
        XCTAssertEqual(sut.thirdBase.playerOn, runner)
        XCTAssertEqual(sut.secondBase, .empty)
        XCTAssertEqual(sut.firstBase, .empty)
    }
    
    func testGroundOut_RunnerOnSecondOneOut_TwoOutsAndRunnerToThird() {
        let runner = Player.empty()
        var sut: Game = .mockWith(
            second: .init(
                playerOn: runner,
                pitcherResponsible: .empty
            ),
            outs: 1
        ) { _, _ in .groundOut }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .groundOut else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.outs, 2)
        XCTAssertEqual(sut.thirdBase.playerOn, runner)
        XCTAssertEqual(sut.secondBase, .empty)
        XCTAssertEqual(sut.firstBase, .empty)
    }
    
    func testGroundOut_RunnerOnThirdNoOuts_OneOutAndRunnerScores() {
        let runner = Player.empty()
        var sut: Game = .mockWith(
            third: .init(
                playerOn: runner,
                pitcherResponsible: .empty
            )
        ) { _, _ in .groundOut }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .groundOut else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.outs, 1)
        XCTAssertEqual(sut.awayTeamScore, 1)
    }
    
    func testGroundOut_RunnerOnThirdOneOut_TwoOutsAndRunnerScores() {
        let runner = Player.empty()
        var sut: Game = .mockWith(
            third: .init(
                playerOn: runner,
                pitcherResponsible: .empty
            ),
            outs: 1
        ) { _, _ in .groundOut }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .groundOut else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.outs, 2)
        XCTAssertEqual(sut.awayTeamScore, 1)
    }
    
    func testGroundOut_BasesEmptyNoOuts_OneOut() {
        var sut: Game = .mockWith() { _, _ in .groundOut }
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .groundOut else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.outs, 1)
    }
    
    func testGroundOut_BasesEmptyOneOut_TwoOuts() {
        var sut: Game = .mockWith(outs: 1) { _, _ in .groundOut }
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .groundOut else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.outs, 2)
    }
}

