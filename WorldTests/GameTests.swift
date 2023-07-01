//
//  GameTests.swift
//  WorldTests
//
//  Created by Shyam Kumar on 6/30/23.
//

@testable import World
import XCTest

final class GameTests: XCTestCase {
    func testGeneratePitch_IncrementsPitchCount() {
        var sut: Game = .mock()
        _ = sut.generatePitch()
        XCTAssertEqual(sut.homeTeamPitcherPitchCount, 1)
    }
    
    func testCallStrike_IncrementsStrikeCount() {
        var sut: Game = .mock()
        sut.makeCall(call: .strike, on: sut.generatePitch())
        XCTAssertEqual(sut.currentStrikes, 1)
    }
    
    func testCallBall_IncrementsBallCount() {
        var sut: Game = .mock()
        sut.makeCall(call: .ball, on: sut.generatePitch())
        XCTAssertEqual(sut.currentBalls, 1)
    }
    
    func testCallStrike_FullCount_ChangesBatterAndIncrementsOuts_AndClearsCount() {
        let player1 = Player.empty()
        let player2 = Player.empty()
        var sut: Game = .mockFullCount(battingOrder: [player1, player2])
        sut.makeCall(call: .strike, on: sut.generatePitch())
        XCTAssertEqual(sut.outs, 1)
        XCTAssertEqual(sut.currentBatter, player2)
        XCTAssertEqual(sut.currentBalls, 0)
        XCTAssertEqual(sut.currentStrikes, 0)
    }
    
    func testCallBall_FullCount_MovesBatterToFirstBase_AndChangesCurrentBatter_AndClearsCount() {
        let player1 = Player.empty()
        let player2 = Player.empty()
        var sut: Game = .mockFullCount(battingOrder: [player1, player2])
        sut.makeCall(call: .ball, on: sut.generatePitch())
        XCTAssertEqual(sut.firstBase.pitcherResponsible, sut.currentPitcher)
        XCTAssertEqual(sut.firstBase.playerOn, player1)
        XCTAssertEqual(sut.currentBatter, player2)
    }
    
    func testCallStrike_FullCountAndTwoOuts_ChangesInningAndTeamAtBat() {
        let homeTeamPlayer = Player.empty()
        let awayTeamPlayer = Player.empty()
        var sut: Game = .mockFullCountAndTwoOuts(
            homeTeamBattingOrder: [homeTeamPlayer],
            awayTeamBattingOrder: [awayTeamPlayer]
        )
        sut.makeCall(call: .strike, on: sut.generatePitch())
        
        XCTAssertEqual(sut.outs, 0)
        XCTAssertEqual(sut.atBat, .home) // bottom of the first
        XCTAssertEqual(sut.halfInning, .bottom)
        XCTAssertEqual(sut.inning, 1)
        XCTAssertEqual(sut.currentBatter, homeTeamPlayer)
        XCTAssertEqual(sut.currentBalls, 0)
        XCTAssertEqual(sut.currentStrikes, 0)
        XCTAssertEqual([sut.firstBase, sut.secondBase, sut.thirdBase], [.empty, .empty, .empty])
    }
    
    func testCallStrike_FullCount_BottomOfTheNinthAndTwoOuts_GameTied_DoesNotEndGame() {
        var sut: Game = .mockFullCountTwoOutsWith(half: .bottom, inning: 9, homeTeamScore: 2, awayTeamScore: 2)
        sut.makeCall(call: .strike, on: sut.generatePitch())
        
        XCTAssertEqual(sut.outs, 0)
        XCTAssertEqual(sut.halfInning, .top)
        XCTAssertEqual(sut.inning, 10)
        XCTAssertEqual(sut.currentBalls, 0)
        XCTAssertEqual(sut.currentStrikes, 0)
        XCTAssertEqual([sut.firstBase, sut.secondBase, sut.thirdBase], [.empty, .empty, .empty])
    }
    
    func testCallStrike_FullCount_BottomOfTheNinthAndTwoOuts_HomeTeamLeading_EndsGame() {
        var sut: Game = .mockFullCountTwoOutsWith(half: .bottom, inning: 9, homeTeamScore: 2, awayTeamScore: 3)
        sut.makeCall(call: .strike, on: sut.generatePitch())
        XCTAssertTrue(sut.isGameOver)
    }
    
    func testCallStrike_FullCount_TopOfTheNinthAndTwoOuts_HomeTeamLeading_EndsGame() {
        var sut: Game = .mockFullCountTwoOutsWith(half: .top, inning: 9, homeTeamScore: 3, awayTeamScore: 2)
        sut.makeCall(call: .strike, on: sut.generatePitch())
        XCTAssertTrue(sut.isGameOver)
    }
    
    func testCallStrike_FullCount_TopOfTheEleventhAndTwoOuts_HomeTeamLeading_EndsGame() {
        var sut: Game = .mockFullCountTwoOutsWith(half: .top, inning: 11, homeTeamScore: 3, awayTeamScore: 2)
        sut.makeCall(call: .strike, on: sut.generatePitch())
        XCTAssertTrue(sut.isGameOver)
    }
    
//    func testMakingCorrectCall_IncreasesUmpireGrade() {
//        var sut: Game = .mock(generateRandomPitch: { .init(x: 0, y: 0 ) })
//        let startUmpireGrade = sut.umpireGame.umpireGrade
//        sut.makeCall(call: .strike, on: sut.generatePitch())
//        XCTAssertGreaterThan(sut.umpireGame.umpireGrade, startUmpireGrade)
//    }
//
//    func testMakingIncorrectCall_DecreasesUmpireGrade() {
//        var sut: Game = .mock(generateRandomPitch: { .init(x: 0, y: 0 ) })
//        let startUmpireGrade = sut.umpireGame.umpireGrade
//        sut.makeCall(call: .ball, on: sut.generatePitch())
//        XCTAssertLessThan(sut.umpireGame.umpireGrade, startUmpireGrade)
//    }
}
