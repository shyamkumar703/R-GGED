//
//  SeasonTests.swift
//  WorldTests
//
//  Created by Shyam Kumar on 7/2/23.
//

@testable import World
import XCTest

final class SeasonTests: XCTestCase {
    func testGenerateSchedule_CreatesAValidMLBSchedule() {
        var sut = Season()
        for team in sut.teams {
            print(team.teamName)
            print("===========================")
            let teamSchedule = sut.schedule.filter({ $0.contains(team: team) })
            let divisionalGames = teamSchedule
                .filter({ $0.isDivisionalSeries })
                .reduce([], { partialResult, series in
                    partialResult + series.plannedGames
                })
            print("Total divisional games: \(divisionalGames.count)")
            let leagueGames = teamSchedule
                .filter({ $0.isLeagueSeries })
                .reduce([], { partialResult, series in
                    partialResult + series.plannedGames
                })
            print("Total league games: \(leagueGames.count)")
            let interleagueGames = teamSchedule
                .filter({ $0.isInterleagueSeries })
                .reduce([], { partialResult, series in
                    partialResult + series.plannedGames
                })
            print("Total interleague games: \(interleagueGames.count)")
            let flattenedTeamSchedule = teamSchedule
                .reduce([], { partialResult, series in
                    partialResult + series.plannedGames
                })
            print("Total games: \(flattenedTeamSchedule.count)")
        }
    }
}
