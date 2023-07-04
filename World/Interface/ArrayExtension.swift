//
//  ArrayExtension.swift
//  World
//
//  Created by Shyam Kumar on 7/4/23.
//

import Foundation

// MARK: - Season Array Extensions
extension Array where Element == Team {
    func teams(league: League, division: Division) -> Self {
        filter({ $0.league == league && $0.division == division })
    }
    
    func teams(league: League, not division: Division) -> Self {
        filter({ $0.league == league && $0.division != division })
    }
    
    func leagueMatchups(for team: Team) -> Self {
        teams(league: team.league, not: team.division)
    }
}

extension Array where Element == Season.PlannedSeries {
    func flatten() -> [Season.PlannedGame] {
        self.reduce([], { partialResult, series in
            partialResult + series.plannedGames
        })
    }
    
    func matchups(team: Team, again division: Division) -> (sevenGameSeries: Int, sixGameSeries: Int, teamMatchups: [Team]) {
        let filteredSeries = filter({ $0.contains(team: team) && $0.not(team: team).division == division })
        var dictionary = [Team: Int]()
        for series in filteredSeries {
            let opposingTeam = series.not(team: team)
            if dictionary[opposingTeam] == nil {
                dictionary[opposingTeam] = series.games
            } else {
                dictionary[opposingTeam]? += series.games
            }
        }
        
        var sevenGameSeries = 0
        var sixGameSeries = 0
        var teamMatchups = [Team]()
        for (_, gameCount) in dictionary {
            if gameCount == 7 {
                sevenGameSeries += 1
                teamMatchups.append(team)
            } else if gameCount == 6 {
                sixGameSeries += 1
                teamMatchups.append(team)
            } else {
                fatalError()
            }
        }
        
        return (sevenGameSeries, sixGameSeries, teamMatchups)
    }
}

extension Array where Element: Identifiable {
    subscript(id: Element.ID) -> Element? {
        filter({ $0.id == id }).first
    }
    
    mutating func remove(id: Element.ID) {
        removeAll(where: { $0.id == id })
    }
}

// MARK: - Team Array Extensions
extension Array where Element == Player {
    var second: Element? {
        guard self.count >= 2 else { return nil }
        return self[1]
    }
    
    func starter(for position: Player.Position) -> Player {
        filter({ $0.position == position })
            .sorted(by: { $0.overall > $1.overall })
            .first!
    }
    
    func backup(for position: Player.Position) -> Player? {
        filter({ $0.position == position })
            .sorted(by: { $0.overall > $1.overall })
            .second
    }
    
    func pitchingRotation() -> NonEmptyCircularArray<Player> {
        NonEmptyCircularArray(
            filter({ $0.position == .pitcher })
                .sorted(by: { $0.pitchingOverall > $1.pitchingOverall })
        )
    }
    
    func battingOrder() -> Self {
        var battingOrder = [Player]()
        var batters = Player.Position.fielders
            .map({ starter(for: $0) })
            .sorted(by: { $0.overall > $1.overall })
        // Add the best backup as DH
        batters.append(
            Player.Position.fielders
                .compactMap({ backup(for: $0) })
                .sorted(by: { $0.overall > $1.overall })
                .first!
        )
        guard batters.count >= 9 else {
            fatalError("Requested batting order with less than 9 eligible batters")
        }
        // Worst of top 4 batting first, best batting cleanup
        battingOrder += Array(batters[0...3].reversed())
        // Rest of batters in order, with worst batter at ninth
        battingOrder += Array(batters[4...8])
        
        return battingOrder
    }
}

// MARK: - NonEmptyCircularArray Array Extensions
extension Array {
    mutating func popFirst() -> Element? {
        guard let first else { return nil }
        self.removeFirst()
        return first
    }
}
