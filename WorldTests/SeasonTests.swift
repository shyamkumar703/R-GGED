//
//  SeasonTests.swift
//  WorldTests
//
//  Created by Shyam Kumar on 7/2/23.
//

@testable import World
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
            
            XCTAssertEqual(teamSchedule.flatten().count, 163)
        }
    }
}
