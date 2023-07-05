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
        guard case .call(let pitch) = sut.generatePitch() else {
            XCTFail()
            return
        }
        sut.makeCall(call: .strike, on: pitch)
        XCTAssertEqual(sut.currentStrikes, 1)
    }
    
    func testCallBall_IncrementsBallCount() {
        var sut: Game = .mock()
        guard case .call(let pitch) = sut.generatePitch() else {
            XCTFail()
            return
        }
        sut.makeCall(call: .ball, on: pitch)
        XCTAssertEqual(sut.currentBalls, 1)
    }
    
    func testCallStrike_FullCount_ChangesBatterAndIncrementsOuts_AndClearsCount() {
        let player1 = Player.empty()
        let player2 = Player.empty()
        var sut: Game = .mockFullCount(battingOrder: [player1, player2])
        guard case .call(let pitch) = sut.generatePitch() else {
            XCTFail()
            return
        }
        sut.makeCall(call: .strike, on: pitch)
        XCTAssertEqual(sut.outs, 1)
        XCTAssertEqual(sut.currentBatter, player2)
        XCTAssertEqual(sut.currentBalls, 0)
        XCTAssertEqual(sut.currentStrikes, 0)
    }
    
    func testCallBall_FullCount_MovesBatterToFirstBase_AndChangesCurrentBatter_AndClearsCount() {
        let player1 = Player.empty()
        let player2 = Player.empty()
        var sut: Game = .mockFullCount(battingOrder: [player1, player2])
        guard case .call(let pitch) = sut.generatePitch() else {
            XCTFail()
            return
        }
        sut.makeCall(call: .ball, on: pitch)
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
        guard case .call(let pitch) = sut.generatePitch() else {
            XCTFail()
            return
        }
        sut.makeCall(call: .strike, on: pitch)
        
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
        guard case .call(let pitch) = sut.generatePitch() else {
            XCTFail()
            return
        }
        sut.makeCall(call: .strike, on: pitch)
        
        XCTAssertEqual(sut.outs, 0)
        XCTAssertEqual(sut.halfInning, .top)
        XCTAssertEqual(sut.inning, 10)
        XCTAssertEqual(sut.currentBalls, 0)
        XCTAssertEqual(sut.currentStrikes, 0)
    }
    
    func testCallStrike_FullCount_BottomOfTheNinthAndTwoOuts_HomeTeamLeading_EndsGame() {
        var sut: Game = .mockFullCountTwoOutsWith(half: .bottom, inning: 9, homeTeamScore: 2, awayTeamScore: 3)
        guard case .call(let pitch) = sut.generatePitch() else {
            XCTFail()
            return
        }
        sut.makeCall(call: .strike, on: pitch)
        XCTAssertTrue(sut.isGameOver)
    }
    
    func testCallStrike_FullCount_TopOfTheNinthAndTwoOuts_HomeTeamLeading_EndsGame() {
        var sut: Game = .mockFullCountTwoOutsWith(half: .top, inning: 9, homeTeamScore: 3, awayTeamScore: 2)
        guard case .call(let pitch) = sut.generatePitch() else {
            XCTFail()
            return
        }
        sut.makeCall(call: .strike, on: pitch)
        XCTAssertTrue(sut.isGameOver)
    }
    
    func testCallStrike_FullCount_TopOfTheEleventhAndTwoOuts_HomeTeamLeading_EndsGame() {
        var sut: Game = .mockFullCountTwoOutsWith(half: .top, inning: 11, homeTeamScore: 3, awayTeamScore: 2)
        guard case .call(let pitch) = sut.generatePitch() else {
            XCTFail()
            return
        }
        sut.makeCall(call: .strike, on: pitch)
        XCTAssertTrue(sut.isGameOver)
    }
    
    func testSingle_MovesBatterToFirst_AssignsBlameCorrectly() {
        let pitcher = Player.empty()
        let batter = Player.empty()
        var sut: Game = .mockWith(batter: batter, pitcher: pitcher) { _, _ in
                .single
        }
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .single else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.firstBase.pitcherResponsible, pitcher)
        XCTAssertEqual(sut.firstBase.playerOn, batter)
    }
    
    func testSingle_ManOnFirst_MovesBatterToFirstAndRunnerToSecond_AssignsBlameCorrectly() {
        let pitcher = Player.empty()
        let runner = Player.empty()
        let batter = Player.empty()
        
        var sut: Game = .mockWith(
            first: .init(
                playerOn: runner,
                pitcherResponsible: pitcher
            ),
            batter: batter,
            pitcher: pitcher
        ) { _, _ in .single }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .single else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.firstBase.pitcherResponsible, pitcher)
        XCTAssertEqual(sut.firstBase.playerOn, batter)
        XCTAssertEqual(sut.secondBase.pitcherResponsible, pitcher)
        XCTAssertEqual(sut.secondBase.playerOn, runner)
    }
    
    func testSingle_ManOnSecond_MovesBatterToFirstAndRunnerHome_AssignsBlameCorrectly() {
        let pitcher = Player.empty()
        let runner = Player.empty()
        let batter = Player.empty()
        
        var sut: Game = .mockWith(
            second: .init(
                playerOn: runner,
                pitcherResponsible: pitcher
            ),
            batter: batter,
            pitcher: pitcher
        ) { _, _ in .single }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .single else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.firstBase.pitcherResponsible, pitcher)
        XCTAssertEqual(sut.firstBase.playerOn, batter)
        XCTAssertEqual(sut.awayTeamScore, 1)
    }
    
    func testSingle_ManOnThird_MovesBatterToFirstAndRunnerHome_AssignsBlameCorrectly() {
        let pitcher = Player.empty()
        let runner = Player.empty()
        let batter = Player.empty()
        
        var sut: Game = .mockWith(
            third: .init(
                playerOn: runner,
                pitcherResponsible: pitcher
            ),
            batter: batter,
            pitcher: pitcher
        ) { _, _ in .single }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .single else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.firstBase.pitcherResponsible, pitcher)
        XCTAssertEqual(sut.firstBase.playerOn, batter)
        XCTAssertEqual(sut.awayTeamScore, 1)
    }
    
    func testDouble_MenOnSecondAndThird_MovesBatterToSecondAndTwoRunsScore() {
        let pitcher = Player.empty()
        let batter = Player.empty()
        
        var sut: Game = .mockWith(
            second: .init(
                playerOn: .empty,
                pitcherResponsible: pitcher
            ),
            third: .init(
                playerOn: .empty,
                pitcherResponsible: pitcher
            ),
            batter: batter,
            pitcher: pitcher
        ) { _, _ in .double }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .double else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.secondBase.pitcherResponsible, pitcher)
        XCTAssertEqual(sut.secondBase.playerOn, batter)
        XCTAssertEqual(sut.awayTeamScore, 2)
    }
    
    func testDouble_BasesLoaded_MovesBatterToSecondAndRunnerToThirdAndTwoRunsScore() {
        let pitcher = Player.empty()
        let runner = Player.empty()
        let batter = Player.empty()
        
        var sut: Game = .mockWith(
            first: .init(
                playerOn: runner,
                pitcherResponsible: pitcher
            ),
            second: .init(
                playerOn: .empty,
                pitcherResponsible: pitcher
            ),
            third: .init(
                playerOn: .empty,
                pitcherResponsible: pitcher
            ),
            batter: batter,
            pitcher: pitcher
        ) { _, _ in .double }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .double else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.secondBase.pitcherResponsible, pitcher)
        XCTAssertEqual(sut.secondBase.playerOn, batter)
        XCTAssertEqual(sut.thirdBase.pitcherResponsible, pitcher)
        XCTAssertEqual(sut.thirdBase.playerOn, runner)
        XCTAssertEqual(sut.awayTeamScore, 2)
    }
    
    func testTriple_BasesLoaded_MovesBatterToThirdAndThreeRunsScore() {
        let pitcher = Player.empty()
        let batter = Player.empty()
        
        var sut: Game = .mockWith(
            first: .init(
                playerOn: .empty,
                pitcherResponsible: pitcher
            ),
            second: .init(
                playerOn: .empty,
                pitcherResponsible: pitcher
            ),
            third: .init(
                playerOn: .empty,
                pitcherResponsible: pitcher
            ),
            batter: batter,
            pitcher: pitcher
        ) { _, _ in .triple }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .triple else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.thirdBase.pitcherResponsible, pitcher)
        XCTAssertEqual(sut.thirdBase.playerOn, batter)
        XCTAssertEqual(sut.awayTeamScore, 3)
    }
    
    func testHomeRun_BasesLoaded_FourRunsScore() {
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
            pitcher: .empty
        ) { _, _ in .homeRun }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .homeRun else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.awayTeamScore, 4)
    }
    
    func testFoul_OneStrike_StrikesIncreaseToTwo() {
        var sut: Game = .mockWith(balls: 0, strikes: 1) { _, _ in .foul }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .foul else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.currentStrikes, 2)
    }
    
    func testFoul_TwoStrikes_StrikesStayAtTwo() {
        var sut: Game = .mockWith(balls: 0, strikes: 2) { _, _ in .foul }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .foul else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.currentStrikes, 2)
    }
    
    func testSwingAndMiss_OneStrike_StrikesIncreaseToTwo() {
        var sut: Game = .mockWith(balls: 0, strikes: 1) { _, _ in .swingAndMiss }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .swingAndMiss else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.currentStrikes, 2)
    }
    
    func testSwingAndMiss_TwoStrikes_BatterIsOut() {
        var sut: Game = .mockWith(balls: 0, strikes: 2) { _, _ in .swingAndMiss }
        
        guard case .noCall(let batterResult) = sut.generatePitch() else {
            XCTFail()
            return
        }
        
        guard batterResult == .swingAndMiss else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sut.currentStrikes, 0)
        XCTAssertEqual(sut.currentBalls, 0)
        XCTAssertEqual(sut.outs, 1)
    }
    
    func testExtraInnings_AddsRunnerOnSecond() {
        var sut: Game = .mockFullCountTwoOutsWith(half: .bottom, inning: 9, homeTeamScore: 0, awayTeamScore: 0)
        guard case .call(let pitch) = sut.generatePitch() else {
            XCTFail()
            return
        }
        sut.makeCall(call: .strike, on: pitch)
        XCTAssertEqual(sut.halfInning, .top)
        XCTAssertEqual(sut.inning, 10)
        XCTAssertNotNil(sut.secondBase.playerOn)
    }
    
    func testSimulate_FinishesGame() {
        var sut: Game = .liveBatter
        sut.simulate()
        XCTAssertNotEqual(sut.homeTeamScore, sut.awayTeamScore)
        print("\(sut.homeTeamScore) to \(sut.awayTeamScore), finished in \(sut.inning) innings")
        XCTAssertTrue(sut.isGameOver)
    }
}
