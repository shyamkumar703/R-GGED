//
//  Team.swift
//  World
//
//  Created by Shyam Kumar on 6/30/23.
//

import SwiftUI

public struct Team {
    var teamName: String
    var teamAbbreviation: String
    var teamColorPrimary: String // hex
    var teamColorSecondary: String // hex
    var league: League
    var division: Division
    var roster: [Player]
    var battingOrder: [Player]
    var pitchingRotation: NonEmptyCircularArray<Player>
}

extension Team {
    /// Mock empty team
    /// For use only in tests where properties of this object don't matter
    static var empty: Self = .init(
        teamName: "",
        teamAbbreviation: "",
        teamColorPrimary: "",
        teamColorSecondary: "",
        league: .national,
        division: .west,
        roster: [.empty, .empty, .empty],
        battingOrder: [.empty, .empty, .empty],
        pitchingRotation: .init(.empty)
    )
    
    static func emptyWith(battingOrder: [Player]) -> Self {
        .init(
            teamName: "",
            teamAbbreviation: "",
            teamColorPrimary: "",
            teamColorSecondary: "",
            league: .national,
            division: .west,
            roster: [.empty, .empty, .empty],
            battingOrder: battingOrder,
            pitchingRotation: .init(.empty)
        )
    }
}

public struct Player: Identifiable, Equatable {
    public var id: UUID
    public var firstName: String
    public var lastName: String
    public var position: Position
    public var age: Int
    public var draftYear: Int
    public var speed: Int
    
    public struct Season {
        var atBats: [AtBat]
        var inningsPitched: Int
        var earnedRuns: Int
    }
    
    public enum Position: Equatable {
        case pitcher
        case firstBase
        case secondBase
        case thirdBase
        case catcher
        case rightField
        case leftField
        case centerField
        case reliefPitcher
        case closer
    }
}

extension Player {
    /// Mock empty player
    /// For use only in tests where properties of this object don't matter
    static var empty: Self = .init(
        id: UUID(),
        firstName: "",
        lastName: "",
        position: .catcher,
        age: 1,
        draftYear: 1,
        speed: 1
    )
    
    static func empty(id: UUID = UUID()) -> Self {
        .init(
            id: id,
            firstName: "",
            lastName: "",
            position: .catcher,
            age: 1,
            draftYear: 1,
            speed: 1
        )
    }
}
