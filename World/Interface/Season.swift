//
//  Season.swift
//  World
//
//  Created by Shyam Kumar on 7/2/23.
//

import Foundation

public struct Season {
    public var year: Int
    public var teams: [Team]
    public var schedule: [PlannedSeries]
    
    public init(teams: [Team] = [], year: Int = 2023) {
        if teams.isEmpty {
            self.teams = Self.generateTeams()
        } else {
            self.teams = teams
        }
        
        self.year = year
        
        // TODO: - Generate schedule
        self.schedule = Self.generateSchedule(for: self.teams).shuffled()
    }
    
    private static func generateSchedule(for teams: [Team]) -> [PlannedSeries] {
        // 13 games against each divisional opponents (52) (3 series' of 3 and 1 of 4 for EACH divisional opponent
        // 6 or 7 games against each team in league (total of 64) (2 series' of 3 or 1 of 3 and 1 of 4 for EACH league opponent)
        // 4 games against one team from opposite league
        // 3 games against all other teams from opposite league
        var schedule = [PlannedSeries]()
        for team in teams {
            generateSchedule(for: team, intermediateSchedule: &schedule, allTeams: teams)
        }
        
        return schedule
    }
    
    private static func generateSchedule(for team: Team, intermediateSchedule: inout [PlannedSeries], allTeams: [Team]) {
        var gamesNeeded = [(Team, Int)]() // team, number of games needed
        // opponents in division
        let divisionalOpponents = allTeams.filter({ $0 != team && $0.league == team.league && $0.division == team.division })
        for opponent in divisionalOpponents {
            let gamesAgainst = gamesAgainst(currentTeam: team, opponent: opponent, schedule: intermediateSchedule)
            if gamesAgainst < 13 {
                gamesNeeded.append((opponent, 13 - gamesAgainst))
            }
        }
        // opponents in league (and not in division)
        let leagueOpponents = allTeams.filter({ $0.league == team.league && $0.division != team.division })
        for opponent in leagueOpponents {
            let gamesAgainst = gamesAgainst(currentTeam: team, opponent: opponent, schedule: intermediateSchedule)
            if gamesAgainst < 6 {
                guard gamesAgainst == 3 || gamesAgainst == 4 || gamesAgainst == 0 else {
                    fatalError("Schedule should only create series' of 3 or 4 games")
                }
                
                // Max out at 6 games for first go-around, second go-around will match teams that need more games to add a fourth game
                gamesNeeded.append((opponent, 6 - gamesAgainst))
            }
        }
        // opponents in opposite league
        // will only worry about 3 games against all teams from opposite league during first go-around, will match teams for a 4th game during second go-around
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
                // TODO: - Implement
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
        
        // MARK: - Second go-around
        // 4 league series' need to be 4 games instead of 3
        // 1 interleague series needs to be 4 games instead of 3
    }
    
    private static func gamesAgainst(currentTeam: Team, opponent: Team, schedule: [PlannedSeries]) -> Int {
        schedule
            .filter({ $0.contains(team: opponent) && $0.contains(team: currentTeam) })
            .reduce(0, { partialResult, series in partialResult + series.plannedGames.count})
    }
    
    private static func generateTeams() -> [Team] {
        return [
            .init(
                teamName: "Arizona",
                teamAbbreviation: "AZ",
                teamColorPrimary: "#A71930",
                teamColorSecondary: "#000000",
                league: .national,
                division: .west
            ),
            .init(
                teamName: "Atlanta",
                teamAbbreviation: "ATL",
                teamColorPrimary: "#CE1141",
                teamColorSecondary: "#13274F",
                league: .national,
                division: .east
            ),
            .init(
                teamName: "Baltimore",
                teamAbbreviation: "BAL",
                teamColorPrimary: "#DF4601",
                teamColorSecondary: "#000000",
                league: .american,
                division: .east
            ),
            .init(
                teamName: "Boston",
                teamAbbreviation: "BOS",
                teamColorPrimary: "#BD3039",
                teamColorSecondary: "#0C2340",
                league: .american,
                division: .east
            ),
            .init(
                teamName: "Chicago",
                teamAbbreviation: "CHI",
                teamColorPrimary: "#0E3386",
                teamColorSecondary: "#CC3433",
                league: .national,
                division: .central
            ),
            .init( // white sox
                teamName: "New Orleans",
                teamAbbreviation: "NOR",
                teamColorPrimary: "#27251F",
                teamColorSecondary: "#C4CED4",
                league: .american,
                division: .central
            ),
            .init(
                teamName: "Cincinnati",
                teamAbbreviation: "CIN",
                teamColorPrimary: "#C6011F",
                teamColorSecondary: "#000000",
                league: .national,
                division: .central
            ),
            .init(
                teamName: "Cleveland",
                teamAbbreviation: "CLE",
                teamColorPrimary: "#00385D",
                teamColorSecondary: "#E50022",
                league: .american,
                division: .central
            ),
            .init(
                teamName: "Colorado",
                teamAbbreviation: "COL",
                teamColorPrimary: "#333366",
                teamColorSecondary: "#131413",
                league: .national,
                division: .west
            ),
            .init(
                teamName: "Detroit",
                teamAbbreviation: "DET",
                teamColorPrimary: "#0C2340",
                teamColorSecondary: "#FA4616",
                league: .american,
                division: .central
            ),
            .init(
                teamName: "Houston",
                teamAbbreviation: "HOU",
                teamColorPrimary: "#002D62",
                teamColorSecondary: "#EB6E1F",
                league: .american,
                division: .west
            ),
            .init(
                teamName: "Kansas City",
                teamAbbreviation: "KC",
                teamColorPrimary: "#004687",
                teamColorSecondary: "#004687",
                league: .american,
                division: .central
            ),
            .init(
                teamName: "Los Angeles",
                teamAbbreviation: "LA",
                teamColorPrimary: "#003263",
                teamColorSecondary: "#BA0021",
                league: .american,
                division: .west
            ),
            .init(
                teamName: "Las Vegas",
                teamAbbreviation: "LV",
                teamColorPrimary: "#005A9C",
                teamColorSecondary: "#EF3E42",
                league: .national,
                division: .west
            ),
            .init(
                teamName: "Miami",
                teamAbbreviation: "MIA",
                teamColorPrimary: "#00A3E0",
                teamColorSecondary: "#EF3340",
                league: .national,
                division: .east
            ),
            .init(
                teamName: "Milwaukee",
                teamAbbreviation: "MIL",
                teamColorPrimary: "#FFC52F",
                teamColorSecondary: "#12284B",
                league: .national,
                division: .central
            ),
            .init(
                teamName: "Minnesota",
                teamAbbreviation: "MIN",
                teamColorPrimary: "#002B5C",
                teamColorSecondary: "#D31145",
                league: .american,
                division: .central
            ),
            .init(
                teamName: "New York",
                teamAbbreviation: "NY",
                teamColorPrimary: "#002D72",
                teamColorSecondary: "#FF5910",
                league: .national,
                division: .east
            ),
            .init( // yankees
                teamName: "North Carolina",
                teamAbbreviation: "NC",
                teamColorPrimary: "#003087",
                teamColorSecondary: "#E4002C",
                league: .american,
                division: .east
            ),
            .init(
                teamName: "Oakland",
                teamAbbreviation: "OAK",
                teamColorPrimary: "#003831",
                teamColorSecondary: "#EFB21E",
                league: .american,
                division: .west
            ),
            .init(
                teamName: "Philadelphia",
                teamAbbreviation: "PHI",
                teamColorPrimary: "#E81828",
                teamColorSecondary: "#002D72",
                league: .national,
                division: .east
            ),
            .init(
                teamName: "Pittsburgh",
                teamAbbreviation: "PIT",
                teamColorPrimary: "#27251F",
                teamColorSecondary: "#FDB827",
                league: .national,
                division: .central
            ),
            .init(
                teamName: "Saint Louis",
                teamAbbreviation: "STL",
                teamColorPrimary: "#C41E3A",
                teamColorSecondary: "#0C2340",
                league: .national,
                division: .central
            ),
            .init(
                teamName: "San Diego",
                teamAbbreviation: "SD",
                teamColorPrimary: "#C41E3A",
                teamColorSecondary: "#FFC425",
                league: .national,
                division: .west
            ),
            .init(
                teamName: "San Francisco",
                teamAbbreviation: "SF",
                teamColorPrimary: "#FD5A1E",
                teamColorSecondary: "#27251F",
                league: .national,
                division: .west
            ),
            .init(
                teamName: "Seattle",
                teamAbbreviation: "SEA",
                teamColorPrimary: "#0C2C56",
                teamColorSecondary: "#005C5C",
                league: .american,
                division: .west
            ),
            .init(
                teamName: "Tampa Bay",
                teamAbbreviation: "TB",
                teamColorPrimary: "#092C5C",
                teamColorSecondary: "#8FBCE6",
                league: .american,
                division: .east
            ),
            .init(
                teamName: "Texas",
                teamAbbreviation: "TX",
                teamColorPrimary: "#003278",
                teamColorSecondary: "#C0111F",
                league: .american,
                division: .west
            ),
            .init(
                teamName: "Toronto",
                teamAbbreviation: "TOR",
                teamColorPrimary: "#134A8E",
                teamColorSecondary: "#1D2D5C",
                league: .american,
                division: .east
            ),
            .init(
                teamName: "Washington",
                teamAbbreviation: "WAS",
                teamColorPrimary: "#AB0003",
                teamColorSecondary: "#14225A",
                league: .national,
                division: .east
            )
        ]
    }
}

extension Season {
    public struct PlannedSeries: CustomStringConvertible {
        var homeTeam: Team
        var awayTeam: Team
        var plannedGames: [PlannedGame]
        var id: UUID
        
        var games: Int {
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
        
        public var description: String {
            "\(awayTeam.teamName) at \(homeTeam.teamName) · \(plannedGames.count) game series"
        }
        
        init(id: UUID = UUID(), homeTeam: Team, awayTeam: Team, games: Int = 3) {
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
        
        func contains(team: Team) -> Bool {
            team == homeTeam || team == awayTeam
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
    }
    
    public struct PlannedGame {
        var homeTeam: Team
        var awayTeam: Team
        var id: UUID = UUID()
        var seriesId: UUID
        // TODO: - Add date at a later time
    }
}

extension Array where Element == Season.PlannedSeries {
    func flatten() -> [Season.PlannedGame] {
        self.reduce([], { partialResult, series in
            partialResult + series.plannedGames
        })
    }
}
