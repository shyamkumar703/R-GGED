//
//  Season.swift
//  World
//
//  Created by Shyam Kumar on 7/2/23.
//

import Foundation

public struct Season: Cacheable, Equatable, Identifiable {
    public static var key: CacheKey = .seasons
    public static var storeOption: CacheStoreOption = .array
    
    public var year: Int
    public var teams: [Team]
    public var schedule: [PlannedSeries]
    public var playoffSchedule: [PlannedSeries] = []
    public var id: Int { year }
    
    var nationalLeaguePlayoffTeams: FixedLengthArray<Team> = .init()
    var americanLeaguePlayoffTeams: FixedLengthArray<Team> = .init()
    
    public var isSeasonOver: Bool {
        schedule.filter({ !$0.isSeriesOver }).count == 0
    }
    
    public var playoffRoundIsOver: Bool {
        playoffSchedule.filter({ !$0.isSeriesOver }).count == 0
    }
    
    public var worldSeriesWinner: Team? {
        guard playoffSchedule.last?.playoffSeries == .world,
              playoffRoundIsOver else { return nil }
        return playoffSchedule.last?.seriesWinner
    }
    
    public init(
        teams: [Team] = [],
        year: Int = 2023,
        userSelectedTeam: Team? = Self.teams.first,
        umpireGamesToGenerate: Int = 30
    ) {
        if teams.isEmpty {
            self.teams = Self.teams
        } else {
            self.teams = teams
        }
        
        self.year = year
        var intermediateSchedule = Self.generateSchedule(for: self.teams).shuffled()
        
        // add umpire games
        for index in 0..<umpireGamesToGenerate {
            var seriesToAddUmpireGameTo = intermediateSchedule[index]
            let gameIndextoAddUmpireGameTo = Int.random(
                in: 0..<seriesToAddUmpireGameTo.games
            )
            seriesToAddUmpireGameTo
                .plannedGames[gameIndextoAddUmpireGameTo]
                .shouldCreateUmpireGame = true
            intermediateSchedule[index] = seriesToAddUmpireGameTo
        }
        
        self.schedule = intermediateSchedule
    }
    
    private static func generateSchedule(for teams: [Team]) -> [PlannedSeries] {
        // 13 games against each divisional opponents (52) (3 series' of 3 and 1 of 4 for EACH divisional opponent
        // 6 or 7 games against each team in league (total of 64) (2 series' of 3 or 1 of 3 and 1 of 4 for EACH league opponent)
        // 4 games against one team from opposite league
        // 3 games against all other teams from opposite league
        var schedule = [PlannedSeries]()
        for team in teams {
            generateSchedule(
                for: team,
                intermediateSchedule: &schedule,
                allTeams: teams
            )
        }
        schedule += generateLeagueSeries(for: teams)
        return schedule
    }
    
    static func generateLeagueSeries(for teams: [Team]) -> [PlannedSeries] {
        var plannedSeries = [PlannedSeries]()
        for team in teams {
            for division in team.division.not {
                var (sevenGameSeriesInDivision, sixGameSeriesInDivision, teamMatchups) = plannedSeries.matchups(team: team, again: division)
                while sevenGameSeriesInDivision < 3 || sixGameSeriesInDivision < 2 {
                    if sevenGameSeriesInDivision < 3 {
                        guard let minSevenGameSeriesInDivisionTeam = teams
                            .teams(league: team.league, division: division)
                            .filter({ !teamMatchups.contains($0) })
                            .sorted(by: {
                                plannedSeries.matchups(team: $0, again: team.division).sevenGameSeries < plannedSeries.matchups(team: $1, again: team.division).sevenGameSeries
                            })
                            .first else {
                            fatalError()
                        }
                        plannedSeries.append(.init(homeTeam: team, awayTeam: minSevenGameSeriesInDivisionTeam, games: 4))
                        plannedSeries.append(.init(homeTeam: minSevenGameSeriesInDivisionTeam, awayTeam: team, games: 3))
                        teamMatchups.append(minSevenGameSeriesInDivisionTeam)
                        sevenGameSeriesInDivision += 1
                    } else if sixGameSeriesInDivision < 2 {
                        guard let minSixGameSeriesInDivisionTeam = teams
                            .teams(league: team.league, division: division)
                            .filter({ !teamMatchups.contains($0) })
                            .sorted(by: {
                                plannedSeries.matchups(team: $0, again: team.division).sixGameSeries < plannedSeries.matchups(team: $1, again: team.division).sixGameSeries
                            })
                                .first else {
                            fatalError()
                        }
                        plannedSeries.append(.init(homeTeam: team, awayTeam: minSixGameSeriesInDivisionTeam, games: 3))
                        plannedSeries.append(.init(homeTeam: minSixGameSeriesInDivisionTeam, awayTeam: team, games: 3))
                        teamMatchups.append(minSixGameSeriesInDivisionTeam)
                        sixGameSeriesInDivision += 1
                    }
                }
            }
        }
        
        return plannedSeries
    }
    
    private static func generateSchedule(
        for team: Team,
        intermediateSchedule: inout [PlannedSeries],
        allTeams: [Team]
    ) {
        var gamesNeeded = [(Team, Int)]() // team, number of games needed
        // opponents in division
        let divisionalOpponents = allTeams.filter({ $0 != team && $0.league == team.league && $0.division == team.division })
        for opponent in divisionalOpponents {
            let gamesAgainst = gamesAgainst(currentTeam: team, opponent: opponent, schedule: intermediateSchedule)
            if gamesAgainst < 13 {
                gamesNeeded.append((opponent, 13 - gamesAgainst))
            }
        }

        // opponents in opposite league
        let interleagueOpponents = allTeams.filter({ $0.league != team.league })
        for opponent in interleagueOpponents {
            let gamesAgainst = gamesAgainst(currentTeam: team, opponent: opponent, schedule: intermediateSchedule)
            if gamesAgainst < 3 {
                guard gamesAgainst == 0 else {
                    fatalError("Schedule should only create series' of 3 or 4 games")
                }
                gamesNeeded.append((opponent, 3))
            }
        }
        
        for (opponent, games) in gamesNeeded {
            if games < 3 {
                // shouldn't have any series less than 3 games
                fatalError()
            } else {
                let fourGameSeries = games % 3
                let threeGameSeries = (games / 3) - fourGameSeries
                guard (threeGameSeries * 3) + (fourGameSeries * 4) == games else {
                    fatalError("Math is wrong")
                }
                for _ in 0..<threeGameSeries {
                    if Bool.random() {
                        intermediateSchedule.append(.init(homeTeam: team, awayTeam: opponent, games: 3))
                    } else {
                        intermediateSchedule.append(.init(homeTeam: opponent, awayTeam: team, games: 3))
                    }
                }
                for _ in 0..<fourGameSeries {
                    if Bool.random() {
                        intermediateSchedule.append(.init(homeTeam: team, awayTeam: opponent, games: 4))
                    } else {
                        intermediateSchedule.append(.init(homeTeam: opponent, awayTeam: team, games: 4))
                    }
                }
            }
        }
    }
    
    private static func gamesAgainst(currentTeam: Team, opponent: Team, schedule: [PlannedSeries]) -> Int {
        schedule
            .filter({ $0.contains(team: opponent) && $0.contains(team: currentTeam) })
            .reduce(0, { partialResult, series in partialResult + series.plannedGames.count})
    }
}

extension Season {
    public struct PlannedSeries: CustomStringConvertible, Codable, Equatable, Identifiable {
        public var homeTeam: Team
        public var awayTeam: Team
        public var plannedGames: [PlannedGame]
        public var id: UUID
        public var playoffSeries: PlayoffSeries?
        
        public var isSeriesOver: Bool {
            plannedGames.filter({ !$0.isGameOver }).count == 0
        }
        
        public var games: Int {
            plannedGames.count
        }
        
        var isDivisionalSeries: Bool {
            homeTeam.league == awayTeam.league && homeTeam.division == awayTeam.division
        }
        
        var isLeagueSeries: Bool {
            homeTeam.league == awayTeam.league && homeTeam.division != awayTeam.division
        }
        
        var isInterleagueSeries: Bool {
            !isDivisionalSeries && !isLeagueSeries
        }
        
        var playoffSeriesLeague: League? {
            guard playoffSeries != nil else { return nil }
            guard homeTeam.league == awayTeam.league else { return nil }
            return homeTeam.league
        }
        
        public var description: String {
            "\(awayTeam.teamName) at \(homeTeam.teamName) · \(plannedGames.count) game series"
        }
        
        public var seriesWinner: Team {
            guard plannedGames.filter({ !$0.isGameOver }).isEmpty else { fatalError() }
            let homeTeamWins = plannedGames.reduce(0, { inter, game in
                if Team.isSameTeam(game.winningTeam, homeTeam) {
                    return inter + 1
                } else {
                    return inter
                }
            })
            let awayTeamWins = games - homeTeamWins
            return homeTeamWins > awayTeamWins ? homeTeam : awayTeam
        }
        
        init(id: UUID = UUID(), homeTeam: Team, awayTeam: Team, games: Int = 3, playoffSeries: PlayoffSeries? = nil) {
            guard homeTeam != awayTeam else {
                fatalError("A series cannot be constructed with the same home and away team")
            }
            self.id = id
            self.homeTeam = homeTeam
            self.awayTeam = awayTeam
            self.plannedGames = (0..<games).map({ _ in
                PlannedGame(
                    homeTeam: homeTeam,
                    awayTeam: awayTeam,
                    seriesId: id
                )
            })
            self.playoffSeries = playoffSeries
        }
        
        mutating func simulate() {
            for index in 0..<plannedGames.count {
                plannedGames[index].simulate()
            }
        }
        
        mutating func addGameToSeries() {
            plannedGames.append(
                PlannedGame(
                    homeTeam: homeTeam,
                    awayTeam: awayTeam,
                    seriesId: id
                )
            )
        }
        
        mutating func removeGameFromSeries() {
            plannedGames.removeLast()
        }
        
        func contains(team: Team) -> Bool {
            team == homeTeam || team == awayTeam
        }
        
        func contains(_ team1: Team, _ team2: Team) -> Bool {
            return contains(team: team1) && contains(team: team2)
        }
        
        func not(team: Team) -> Team {
            if homeTeam == team {
                return awayTeam
            } else if awayTeam == team {
                return homeTeam
            } else {
                fatalError("Team \(team.teamName) not participating in series")
            }
        }
        
        public enum PlayoffSeries: Codable, Equatable {
            case wildCard
            case divisional
            case league
            case world
        }
    }
    
    public struct PlannedGame: Codable, Equatable {
        var homeTeam: Team
        var awayTeam: Team
        var id: UUID = UUID()
        var seriesId: UUID
        var game: Game?
        var shouldCreateUmpireGame: Bool = false
        // TODO: - Add date at a later time
        
        var isGameOver: Bool {
            game?.isGameOver == true
        }
        
        var winningTeam: Team {
            guard let game,
                  isGameOver else { fatalError() }
            return game.winningTeam
        }
        
        public mutating func simulate() {
            guard !shouldCreateUmpireGame else { fatalError() }
            var game: Game = .init(homeTeam: homeTeam, awayTeam: awayTeam)
            game.simulate()
            self.game = game
        }
        
        public mutating func createGame() {
            self.game = .init(
                homeTeam: homeTeam,
                awayTeam: awayTeam,
                umpireGame: shouldCreateUmpireGame ? .some(.new) : .none
            )
        }
        
        func contains(team: Team) -> Bool {
            team == homeTeam || team == awayTeam
        }
        
        func contains(_ team1: Team, _ team2: Team) -> Bool {
            return contains(team: team1) && contains(team: team2)
        }
    }
}
