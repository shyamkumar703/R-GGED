//
//  FlyOutTests.swift
//  WorldTests
//
//  Created by Shyam Kumar on 7/1/23.
//

@testable import World
import XCTest

final class FlyOutTests: XCTestCase {
    func testFlyOut_BasesEmpty_ResultsInAnOut() {
        var sut: Game = .mockWith() { _, _ in .flyOut }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .flyOut else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.outs, 1)
        XCTAssertEqual(sut.firstBase, .empty)
        XCTAssertEqual(sut.secondBase, .empty)
        XCTAssertEqual(sut.thirdBase, .empty)
        XCTAssertEqual(sut.awayTeamScore, 0)
    }
    
    func testFlyOut_BasesLoadedNoOuts_OneRunScoresAndOneOutRecorded() {
        let runnerOnFirst = Player.empty()
        let runnerOnSecond = Player.empty()
        var sut: Game = .mockWith(
            first: .init(playerOn: runnerOnFirst, pitcherResponsible: .empty),
            second: .init(playerOn: runnerOnSecond, pitcherResponsible: .empty),
            third: .init(playerOn: .empty, pitcherResponsible: .empty)
        ) { _, _ in .flyOut }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .flyOut else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.secondBase.playerOn, runnerOnFirst)
        XCTAssertEqual(sut.thirdBase.playerOn, runnerOnSecond)
        XCTAssertEqual(sut.firstBase, .empty)
        XCTAssertEqual(sut.outs, 1)
        XCTAssertEqual(sut.awayTeamScore, 1)
    }
    
    func testFlyOut_FirstAndSecondNoOuts_RunnersTagAndOneOutRecorded() {
        let runnerOnFirst = Player.empty()
        let runnerOnSecond = Player.empty()
        var sut: Game = .mockWith(
            first: .init(playerOn: runnerOnFirst, pitcherResponsible: .empty),
            second: .init(playerOn: runnerOnSecond, pitcherResponsible: .empty)
        ) { _, _ in .flyOut }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .flyOut else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.secondBase.playerOn, runnerOnFirst)
        XCTAssertEqual(sut.thirdBase.playerOn, runnerOnSecond)
        XCTAssertEqual(sut.firstBase, .empty)
        XCTAssertEqual(sut.outs, 1)
        XCTAssertEqual(sut.awayTeamScore, 0)
    }
    
    func testFlyOut_FirstAndThirdNoOuts_RunnersTagAndOneRunScoresAndOneOutRecorded() {
        let runnerOnFirst = Player.empty()
        var sut: Game = .mockWith(
            first: .init(playerOn: runnerOnFirst, pitcherResponsible: .empty),
            third: .init(playerOn: .empty, pitcherResponsible: .empty)
        ) { _, _ in .flyOut }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .flyOut else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.secondBase.playerOn, runnerOnFirst)
        XCTAssertEqual(sut.firstBase, .empty)
        XCTAssertEqual(sut.thirdBase, .empty)
        XCTAssertEqual(sut.awayTeamScore, 1)
        XCTAssertEqual(sut.outs, 1)
    }
    
    func testFlyOut_SecondAndThirdNoOuts_RunnersTagAndOneRunScoresAndOneOutRecorded() {
        let runnerOnSecond = Player.empty()
        var sut: Game = .mockWith(
            second: .init(playerOn: runnerOnSecond, pitcherResponsible: .empty),
            third: .init(playerOn: .empty, pitcherResponsible: .empty)
        ) { _, _ in .flyOut }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .flyOut else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.thirdBase.playerOn, runnerOnSecond)
        XCTAssertEqual(sut.secondBase, .empty)
        XCTAssertEqual(sut.firstBase, .empty)
        XCTAssertEqual(sut.awayTeamScore, 1)
        XCTAssertEqual(sut.outs, 1)
    }
    
    func testFlyOut_RunnerOnFirst_RunnerTagsAndOneOutRecorded() {
        let runnerOnFirst = Player.empty()
        var sut: Game = .mockWith(
            first: .init(playerOn: runnerOnFirst, pitcherResponsible: .empty)
        ) { _, _ in .flyOut }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .flyOut else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.secondBase.playerOn, runnerOnFirst)
        XCTAssertEqual(sut.firstBase, .empty)
        XCTAssertEqual(sut.thirdBase, .empty)
        XCTAssertEqual(sut.outs, 1)
        XCTAssertEqual(sut.awayTeamScore, 0)
    }
    
    func testFlyOut_RunnerOnSecond_RunnerTagsAndOneOutRecorded() {
        let runnerOnSecond = Player.empty()
        var sut: Game = .mockWith(
            second: .init(playerOn: runnerOnSecond, pitcherResponsible: .empty)
        ) { _, _ in .flyOut }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .flyOut else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.thirdBase.playerOn, runnerOnSecond)
        XCTAssertEqual(sut.secondBase, .empty)
        XCTAssertEqual(sut.firstBase, .empty)
        XCTAssertEqual(sut.outs, 1)
        XCTAssertEqual(sut.awayTeamScore, 0)
    }
    
    func testFlyOut_RunnerOnThird_RunnerTagsAndScoresAndOneOutRecorded() {
        var sut: Game = .mockWith(
            third: .init(playerOn: .empty, pitcherResponsible: .empty)
        ) { _, _ in .flyOut }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .flyOut else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.awayTeamScore, 1)
        XCTAssertEqual(sut.firstBase, .empty)
        XCTAssertEqual(sut.secondBase, .empty)
        XCTAssertEqual(sut.thirdBase, .empty)
        XCTAssertEqual(sut.outs, 1)
    }
}
