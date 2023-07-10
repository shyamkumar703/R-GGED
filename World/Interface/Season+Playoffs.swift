//
//  Season+Playoffs.swift
//  World
//
//  Created by Shyam Kumar on 7/10/23.
//

import Foundation

// TODO: - Generate league round + WS; refactor and add tests

extension Season {
    struct Record: Comparable, Equatable {
        var wins: Int
        var losses: Int
        var team: Team
        
        static func < (lhs: Season.Record, rhs: Season.Record) -> Bool {
            lhs.wins < rhs.wins
        }
    }
    
    public mutating func generateFirstRoundOfPlayoffs() {
        guard isSeasonOver else { fatalError("season is not over") }
        self.nationalLeaguePlayoffTeams = .init(getPlayoffTeams(for: .national))
        self.americanLeaguePlayoffTeams = .init(getPlayoffTeams(for: .american))
        /// 1 and 2 seeds in each league get first-round byes
        /// In the Wild Card Series, 3 vs 6 and 4 vs 5. Wild Card Series are each 3 games
        /// 1 seed faces winner of 4 vs 5, and 2 seed faces winner of 3 vs 6

        // 3 vs 6 matchup
        // FixedLengthArray is 1-INDEXED
        playoffSchedule.append(.init(homeTeam: nationalLeaguePlayoffTeams[3], awayTeam: nationalLeaguePlayoffTeams[6], games: 3))
        playoffSchedule.append(.init(homeTeam: americanLeaguePlayoffTeams[3], awayTeam: americanLeaguePlayoffTeams[6], games: 3))
        
        // 4 vs 5 matchup
        playoffSchedule.append(.init(homeTeam: nationalLeaguePlayoffTeams[4], awayTeam: nationalLeaguePlayoffTeams[5], games: 3))
        playoffSchedule.append(.init(homeTeam: americanLeaguePlayoffTeams[4], awayTeam: americanLeaguePlayoffTeams[5], games: 3))
    }
    
    public mutating func generateDivisionalRoundOfPlayoffs() {
        guard playoffSchedule.filter({ !$0.isSeriesOver }).isEmpty else { fatalError() }
        playoffSchedule.forEach({ series in
            switch series.playoffSeriesLeague {
            case .national: self.nationalLeaguePlayoffTeams.remove(series.not(team: series.seriesWinner))
            case .american: self.americanLeaguePlayoffTeams.remove(series.not(team: series.seriesWinner))
            case .none: fatalError() // should never get here, teams should all be in the same league in first rd
            }
        })
        
        // 1 seed plays winner of 4 and 5
        playoffSchedule.append(
            .init(
                homeTeam: nationalLeaguePlayoffTeams[1],
                awayTeam: nationalLeaguePlayoffTeams.get(4) ?? nationalLeaguePlayoffTeams[5]
            )
        )
        
        playoffSchedule.append(
            .init(
                homeTeam: americanLeaguePlayoffTeams[1],
                awayTeam: americanLeaguePlayoffTeams.get(4) ?? americanLeaguePlayoffTeams[5]
            )
        )
        
        // 2 seed plays winner of 3 and 6
        playoffSchedule.append(
            .init(
                homeTeam: nationalLeaguePlayoffTeams[2],
                awayTeam: nationalLeaguePlayoffTeams.get(3) ?? nationalLeaguePlayoffTeams[6]
            )
        )
        
        playoffSchedule.append(
            .init(
                homeTeam: americanLeaguePlayoffTeams[2],
                awayTeam: americanLeaguePlayoffTeams.get(3) ?? americanLeaguePlayoffTeams[6]
            )
        )
    }
    
    public mutating func generateLeagueRoundOfPlayoffs() {
    }
    
    func getPlayoffTeams(for league: League) -> [Team] {
        // TODO: - Edge cases (like ties, etc.)
        let leagueStandings = Array(
            Self.teams
                .map({ schedule.record(for: $0) })
                .sorted()
                .reversed()
        )
        let divisionWinners = Division
            .allCases
            .compactMap({ division in
                leagueStandings.first(
                    where: { record in
                        record.team.division == division
                    }
                )
            })
        guard divisionWinners.count == Division.allCases.count else { fatalError() }
        let wildCardTeams = Array(
            leagueStandings
                .filter({ currentRecord in
                    !divisionWinners.contains(where: { record in
                        record.team == currentRecord.team
                    })
                })
                .prefix(3)
        )
        
        return (divisionWinners + wildCardTeams).map({ $0.team })
    }
}
