//
//  ArrayExtensionTests.swift
//  WorldTests
//
//  Created by Shyam Kumar on 7/4/23.
//

@testable import World
import XCTest

final class ArrayExtensionTests: XCTestCase {
    func testTeams_ReturnsTeamsInLeagueAndDivision() {
        let team1 = Team.emptyWith(league: .national, division: .west)
        let team2 = Team.emptyWith(league: .national, division: .west)
        let sut: [Team] = [
            team1,
            team2,
            .emptyWith(league: .american, division: .east),
            .emptyWith(league: .american, division: .west)
        ]
        
        XCTAssertEqual([team1, team2], sut.teams(league: .national, division: .west))
    }
    
    func testTeams_ReturnsTeamsInLeagueAndNotInDivision() {
        let team1 = Team.emptyWith(league: .american, division: .east)
        let team2 = Team.emptyWith(league: .american, division: .west)
        let sut: [Team] = [
            team1,
            team2,
            .emptyWith(league: .american, division: .central),
            .emptyWith(league: .american, division: .central)
        ]
        
        XCTAssertEqual([team1, team2], sut.teams(league: .american, not: .central))
    }
    
    func testLeagueMatchups_ReturnsTeamsInLeagueAndNotInDivision() {
        let team1 = Team.emptyWith(league: .american, division: .east)
        let team2 = Team.emptyWith(league: .american, division: .west)
        let testTeam: Team = .emptyWith(league: .american, division: .central)
        let sut: [Team] = [
            team1,
            team2,
            .emptyWith(league: .american, division: .central),
        ]
        
        XCTAssertEqual([team1, team2], sut.leagueMatchups(for: testTeam))
    }
    
    func testFlattenSeries_ReturnsCorrectArrayOfGames() {
        let homeTeam = Team.empty
        let awayTeam = Team.empty
        let series1 = Season.PlannedSeries(
            homeTeam: homeTeam,
            awayTeam: awayTeam
        )
        let series2 = Season.PlannedSeries(
            homeTeam: homeTeam,
            awayTeam: awayTeam
        )
        let sut = [series1, series2].flatten()
        XCTAssertEqual(sut.count, 6)
        for game in sut {
            XCTAssertEqual(game.homeTeam, homeTeam)
            XCTAssertEqual(game.awayTeam, awayTeam)
        }
    }
    
    func testMatchupsAgainstDivision_ReturnsCorrectValues() {
        let team = Team.emptyWith(league: .national, division: .west)
        let eastTeam1 = Team.emptyWith(league: .national, division: .east)
        let eastTeam2 = Team.emptyWith(league: .national, division: .east)
        let plannedSeries: [Season.PlannedSeries] = [
            .init(homeTeam: team, awayTeam: eastTeam1, games: 4),
            .init(homeTeam: team, awayTeam: eastTeam1, games: 3),
            .init(homeTeam: team, awayTeam: eastTeam2, games: 3),
            .init(homeTeam: team, awayTeam: eastTeam2, games: 3),
            .init(homeTeam: team, awayTeam: .empty),
            .init(homeTeam: team, awayTeam: .empty)
        ]
        let sut = plannedSeries.matchups(team: team, again: .east)
        XCTAssertEqual(sut.sevenGameSeries, 1)
        XCTAssertEqual(sut.sixGameSeries, 1)
        XCTAssertEqual(sut.teamMatchups.count, 2)
    }
}
