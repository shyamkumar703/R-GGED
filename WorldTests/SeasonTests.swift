//
//  SeasonTests.swift
//  WorldTests
//
//  Created by Shyam Kumar on 7/2/23.
//

@testable import World
import Foundation
import XCTest

final class SeasonTests: XCTestCase {
    func testCreatePlannedSeries_RespectsNumberOfGamesAdded() {
        let sut = Season.PlannedSeries(homeTeam: .empty, awayTeam: .empty)
        XCTAssertEqual(sut.games, 3) // default value
        
        let sut2 = Season.PlannedSeries(homeTeam: .empty, awayTeam: .empty, games: 4)
        XCTAssertEqual(sut2.games, 4)
        
        let sut3 = Season.PlannedSeries(homeTeam: .empty, awayTeam: .empty, games: 2)
        XCTAssertEqual(sut3.games, 2)
    }
    
    func testGenerateSchedule_CreatesAValidMLBSchedule() {
        let sut = Season()
        for team in sut.teams {
            let teamSchedule = sut.schedule.filter({ $0.contains(team: team) })
            XCTAssertEqual(teamSchedule.flatten().count, 163)
            
            let divisionalGames = teamSchedule
                .filter({ $0.isDivisionalSeries })
                .flatten()
                .count
            XCTAssertEqual(divisionalGames, 52)
            
            let leagueGames = teamSchedule
                .filter({ $0.isLeagueSeries })
                .flatten()
                .count
            XCTAssertEqual(leagueGames, 66)
            
            let interleagueGames = teamSchedule
                .filter({ $0.isInterleagueSeries })
                .flatten()
                .count
            XCTAssertEqual(interleagueGames, 45)
        }
    }
    
    func testGenerateSchedule_AddsUmpireGamesCorrectly() {
        guard let shouldRun = ProcessInfo.processInfo.environment["shouldRunLongTests"],
              shouldRun == "true" else {
            // skip long-running test in this case
            return
        }
        
        let sut = Season(umpireGamesToGenerate: 30)
        XCTAssertEqual(
            sut.schedule.flatten().reduce(0, { inter, curr in
                curr.shouldCreateUmpireGame ? inter + 1 : inter
            }),
            30
        )
    }
    
    func testCacheSeason_WorksAsExpected() {
        guard let shouldRun = ProcessInfo.processInfo.environment["shouldRunLongTests"],
              shouldRun == "true" else {
            // skip long-running cache test in this case
            return
        }
        
        Season.clearCache()
        guard case .array(let cachedArrayAfterFirstClear) = Season.read() else {
            XCTFail()
            return
        }
        XCTAssertEqual(cachedArrayAfterFirstClear.count, 0)
        
        let sut: Season = .init()
        let expectation = XCTestExpectation(description: "Wait to store..")
        sut.store { _ in expectation.fulfill() }
        wait(for: [expectation])
        
        guard case .array(let cachedSutArray) = Season.read() else {
            XCTFail()
            return
        }
        guard let cachedSut = cachedSutArray.first else {
            XCTFail()
            return
        }
        XCTAssertEqual(cachedSut, sut)
        
        Season.clearCache()
        guard case .array(let cachedArrayAfterSecondClear) = Season.read() else {
            XCTFail()
            return
        }
        XCTAssertEqual(cachedArrayAfterSecondClear.count, 0)
    }
    
    func testCacheSeason_AfterGameSimulation_WorksAsExpected() {
        guard let shouldRun = ProcessInfo.processInfo.environment["shouldRunLongTests"],
              shouldRun == "true" else {
            // skip long-running cache test in this case
            return
        }
        Season.clearCache()
        var sut = Season()
        sut.schedule[0].plannedGames[0].simulate()
        XCTAssertNotNil(sut.schedule.first?.plannedGames.first?.game)
        
        let expectation = XCTestExpectation(description: "Wait to store..")
        sut.store { _ in expectation.fulfill() }
        wait(for: [expectation])
        
        guard case .array(let cachedSutArray) = Season.read() else {
            XCTFail()
            return
        }
        guard let cachedSut = cachedSutArray.first else {
            XCTFail()
            return
        }
        XCTAssertEqual(sut, cachedSut)
        Season.clearCache()
    }
    
    // MARK: - Playoff tests
    func testGetPlayoffTeams_GeneratesSixUniqueTeamsForEachLeague() {
        guard let shouldRun = ProcessInfo.processInfo.environment["shouldRunLongTests"],
              shouldRun == "true" else {
            // skip long-running test in this case
            return
        }
        
        var sut = Season(umpireGamesToGenerate: 0)
        for index in 0..<sut.schedule.count {
            sut.schedule[index].simulate()
        }
        
        let nationalLeaguePlayoffTeams = sut.getPlayoffTeams(for: .national)
        let americanLeaguePlayoffTeams = sut.getPlayoffTeams(for: .american)
        XCTAssertEqual(nationalLeaguePlayoffTeams.count, 6)
        XCTAssertEqual(americanLeaguePlayoffTeams.count, 6)
        XCTAssertEqual(Set(nationalLeaguePlayoffTeams).count, 6)
        XCTAssertEqual(Set(nationalLeaguePlayoffTeams).count, 6)
        
        XCTAssert(nationalLeaguePlayoffTeams.filter({ $0.league != .national }).isEmpty)
        XCTAssert(americanLeaguePlayoffTeams.filter({ $0.league != .american }).isEmpty)
    }
    
    func testPlayoffs_WorksAsExpected() {
        guard let shouldRun = ProcessInfo.processInfo.environment["shouldRunLongTests"],
              shouldRun == "true" else {
            // skip long-running test in this case
            return
        }
        
        var sut = Season(umpireGamesToGenerate: 0)
        for index in 0..<sut.schedule.count {
            sut.schedule[index].simulate()
        }
        
        XCTAssertTrue(sut.generateNextRoundOfPlayoffs())
        
        for index in 0..<sut.playoffSchedule.count {
            sut.playoffSchedule[index].simulate()
        }
        
        XCTAssert(sut.playoffRoundIsOver)
        
        XCTAssertTrue(sut.generateNextRoundOfPlayoffs())
        
        for index in 0..<sut.playoffSchedule.count {
            sut.playoffSchedule[index].simulate()
        }
        
        XCTAssert(sut.playoffRoundIsOver)
        
        XCTAssertTrue(sut.generateNextRoundOfPlayoffs())
        
        XCTAssertEqual(sut.nationalLeaguePlayoffTeams.count, 2)
        XCTAssertEqual(sut.americanLeaguePlayoffTeams.count, 2)
        
        for index in 0..<sut.playoffSchedule.count {
            sut.playoffSchedule[index].simulate()
        }
        
        XCTAssertTrue(sut.generateNextRoundOfPlayoffs())
        
        XCTAssertEqual(sut.nationalLeaguePlayoffTeams.count, 1)
        XCTAssertEqual(sut.americanLeaguePlayoffTeams.count, 1)
        
        for index in 0..<sut.playoffSchedule.count {
            sut.playoffSchedule[index].simulate()
        }
        
        XCTAssertNotNil(sut.worldSeriesWinner)
        
        XCTAssertFalse(sut.generateNextRoundOfPlayoffs())
    }
}
