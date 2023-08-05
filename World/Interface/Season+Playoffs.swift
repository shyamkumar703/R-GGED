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
    
    @discardableResult public mutating func generateNextRoundOfPlayoffs() -> Bool {
        guard isSeasonOver && playoffRoundIsOver else { return false }
        guard playoffSchedule.last?.playoffSeries != .world else { return false }
        if playoffSchedule.isEmpty {
            generateFirstRoundOfPlayoffs()
        } else {
            switch playoffSchedule.last?.playoffSeries {
            case .none:
                return false
            case .wildCard:
                generateDivisionalRoundOfPlayoffs()
                return true
            case .divisional:
                generateLeagueRoundOfPlayoffs()
                return true
            case .league:
                generateWorldSeries()
                return true
            case .world:
                return false
            }
        }
        
        return true
    }
    
    private mutating func generateFirstRoundOfPlayoffs() {
        guard isSeasonOver else { fatalError("season is not over") }
        self.nationalLeaguePlayoffTeams = .init(getPlayoffTeams(for: .national))
        self.americanLeaguePlayoffTeams = .init(getPlayoffTeams(for: .american))
        /// 1 and 2 seeds in each league get first-round byes
        /// In the Wild Card Series, 3 vs 6 and 4 vs 5. Wild Card Series are each 3 games
        /// 1 seed faces winner of 4 vs 5, and 2 seed faces winner of 3 vs 6
        
        // 3 vs 6 matchup
        // FixedLengthArray is 1-INDEXED
        playoffSchedule.append(.init(homeTeam: nationalLeaguePlayoffTeams[3], awayTeam: nationalLeaguePlayoffTeams[6], games: 3, playoffSeries: .wildCard))
        playoffSchedule.append(.init(homeTeam: americanLeaguePlayoffTeams[3], awayTeam: americanLeaguePlayoffTeams[6], games: 3, playoffSeries: .wildCard))
        
        // 4 vs 5 matchup
        playoffSchedule.append(.init(homeTeam: nationalLeaguePlayoffTeams[4], awayTeam: nationalLeaguePlayoffTeams[5], games: 3, playoffSeries: .wildCard))
        playoffSchedule.append(.init(homeTeam: americanLeaguePlayoffTeams[4], awayTeam: americanLeaguePlayoffTeams[5], games: 3, playoffSeries: .wildCard))
        
        playoffSchedule.forEach({ print("\($0.homeTeam) @ \($0.awayTeam)") })
    }
    
    private mutating func generateDivisionalRoundOfPlayoffs() {
        guard playoffRoundIsOver else { fatalError() }
        playoffSchedule
            .filter({ $0.playoffSeries == .wildCard })
            .forEach({ series in
                guard series.homeTeam.league == series.awayTeam.league else {
                    fatalError()
                }
                switch series.homeTeam.league {
                case .national: self.nationalLeaguePlayoffTeams.remove(series.not(team: series.seriesWinner))
                case .american: self.americanLeaguePlayoffTeams.remove(series.not(team: series.seriesWinner))
                }
            })
        
        // 1 seed plays winner of 4 and 5
        playoffSchedule.append(
            .init(
                homeTeam: nationalLeaguePlayoffTeams[1],
                awayTeam: nationalLeaguePlayoffTeams.get(4) ?? nationalLeaguePlayoffTeams[5],
                games: 5,
                playoffSeries: .divisional
            )
        )
        
        playoffSchedule.append(
            .init(
                homeTeam: americanLeaguePlayoffTeams[1],
                awayTeam: americanLeaguePlayoffTeams.get(4) ?? americanLeaguePlayoffTeams[5],
                games: 5,
                playoffSeries: .divisional
            )
        )
        
        // 2 seed plays winner of 3 and 6
        playoffSchedule.append(
            .init(
                homeTeam: nationalLeaguePlayoffTeams[2],
                awayTeam: nationalLeaguePlayoffTeams.get(3) ?? nationalLeaguePlayoffTeams[6],
                games: 5,
                playoffSeries: .divisional
            )
        )
        
        playoffSchedule.append(
            .init(
                homeTeam: americanLeaguePlayoffTeams[2],
                awayTeam: americanLeaguePlayoffTeams.get(3) ?? americanLeaguePlayoffTeams[6],
                games: 5,
                playoffSeries: .divisional
            )
        )
    }
    
    private mutating func generateLeagueRoundOfPlayoffs() {
        guard playoffRoundIsOver else { fatalError() }
        playoffSchedule
            .filter({ $0.playoffSeries == .divisional })
            .forEach({ series in
                guard series.homeTeam.league == series.awayTeam.league else {
                    fatalError()
                }
                switch series.homeTeam.league {
                case .national: self.nationalLeaguePlayoffTeams.remove(series.not(team: series.seriesWinner))
                case .american: self.americanLeaguePlayoffTeams.remove(series.not(team: series.seriesWinner))
                }
            })
        
        // Winner of 1 seed vs winner of 4 seed and 5 seed plays the winner of 2 seed vs winner of 3rd and 6th seed
        playoffSchedule.append(
            .init(
                homeTeam: nationalLeaguePlayoffTeams.get(1) ?? nationalLeaguePlayoffTeams.get(4) ?? nationalLeaguePlayoffTeams[5],
                awayTeam: nationalLeaguePlayoffTeams.get(2) ?? nationalLeaguePlayoffTeams.get(3) ?? nationalLeaguePlayoffTeams[6],
                games: 7,
                playoffSeries: .league
            )
        )
        
        playoffSchedule.append(
            .init(
                homeTeam: americanLeaguePlayoffTeams.get(1) ?? americanLeaguePlayoffTeams.get(4) ?? americanLeaguePlayoffTeams[5],
                awayTeam: americanLeaguePlayoffTeams.get(2) ?? americanLeaguePlayoffTeams.get(3) ?? americanLeaguePlayoffTeams[6],
                games: 7,
                playoffSeries: .league
            )
        )
    }
    
    private mutating func generateWorldSeries() {
        guard playoffRoundIsOver else { fatalError() }
        playoffSchedule
            .filter({ $0.playoffSeries == .league })
            .forEach({ series in
                guard series.homeTeam.league == series.awayTeam.league else {
                    fatalError()
                }
                switch series.homeTeam.league {
                case .national: self.nationalLeaguePlayoffTeams.remove(series.not(team: series.seriesWinner))
                case .american: self.americanLeaguePlayoffTeams.remove(series.not(team: series.seriesWinner))
                }
            })
        guard nationalLeaguePlayoffTeams.count == 1,
              let nationalLeagueWorldSeriesTeam = nationalLeaguePlayoffTeams.elements.first else { fatalError() }
        guard americanLeaguePlayoffTeams.count == 1,
              let americanLeagueWorldSeriesTeam = americanLeaguePlayoffTeams.elements.first else { fatalError() }
        
        playoffSchedule.append(
            .init(
                homeTeam: nationalLeagueWorldSeriesTeam,
                awayTeam: americanLeagueWorldSeriesTeam,
                games: 7,
                playoffSeries: .world
            )
        )
    }
    
    func getPlayoffTeams(for league: League) -> [Team] {
        // TODO: - Edge cases (like ties, etc.)
        let leagueStandings = Array(
            Self.teams
                .filter({ $0.league == league })
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
