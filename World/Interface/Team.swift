//
//  Team.swift
//  World
//
//  Created by Shyam Kumar on 6/30/23.
//

import SwiftUI

public struct Team: Equatable, Identifiable, Hashable {
    public var id: String {
        teamName
    }
    var teamName: String
    var teamAbbreviation: String
    var teamColorPrimary: String // hex
    var teamColorSecondary: String // hex
    var league: League
    var division: Division
    var roster: [Player]
    var battingOrder: [Player]
    var pitchingRotation: NonEmptyCircularArray<Player>
    
    init(
        teamName: String,
        teamAbbreviation: String,
        teamColorPrimary: String,
        teamColorSecondary: String,
        league: League,
        division: Division,
        roster: [Player],
        battingOrder: [Player],
        pitchingRotation: NonEmptyCircularArray<Player>
    ) {
        self.teamName = teamName
        self.teamAbbreviation = teamAbbreviation
        self.teamColorPrimary = teamColorPrimary
        self.teamColorSecondary = teamColorSecondary
        self.league = league
        self.division = division
        self.roster = roster
        self.battingOrder = battingOrder
        self.pitchingRotation = pitchingRotation
    }
    
    public init(
        teamName: String,
        teamAbbreviation: String,
        teamColorPrimary: String,
        teamColorSecondary: String,
        league: League,
        division: Division
    ) {
        self.teamName = teamName
        self.teamAbbreviation = teamAbbreviation
        self.teamColorPrimary = teamColorPrimary
        self.teamColorSecondary = teamColorSecondary
        self.league = league
        self.division = division
        self.roster = Player.generateRandomRoster()
        self.battingOrder = self.roster.battingOrder()
        self.pitchingRotation = self.roster.pitchingRotation()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public enum League {
    case national
    case american
}

public enum Division: CaseIterable {
    case east
    case central
    case west
    
    var not: [Division] {
        Division.allCases.filter({ $0 != self })
    }
}

extension Team {
    /// Mock empty team
    /// For use only in tests where properties of this object don't matter
    static var empty: Self {
        .init(
            teamName: UUID().uuidString,
            teamAbbreviation: UUID().uuidString,
            teamColorPrimary: "",
            teamColorSecondary: "",
            league: .national,
            division: .west,
            roster: [.empty, .empty, .empty],
            battingOrder: [.empty, .empty, .empty],
            pitchingRotation: .init(.empty)
        )
    }
    
    static func emptyWith(league: League, division: Division) -> Self {
        .init(
            teamName: UUID().uuidString,
            teamAbbreviation: UUID().uuidString,
            teamColorPrimary: "",
            teamColorSecondary: "",
            league: league,
            division: division,
            roster: [.empty, .empty, .empty],
            battingOrder: [.empty, .empty, .empty],
            pitchingRotation: .init(.empty)
        )
    }
    
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
    
    static func emptyWith(pitchingRotation: [Player]) -> Self {
        .init(
            teamName: "",
            teamAbbreviation: "",
            teamColorPrimary: "",
            teamColorSecondary: "",
            league: .national,
            division: .west,
            roster: [.empty, .empty, .empty],
            battingOrder: [.empty, .empty, .empty],
            pitchingRotation: .init(pitchingRotation)
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
    public var contactPercentage: Int // between 1 and 100
    public var power: Int // between 1 and 100
    public var plateDiscipline: Int // between 1 and 100
    var overall: Int {
        (speed + contactPercentage + power + plateDiscipline) / 4
    }
    
    public var pitchingControl: Int // between 1 and 100
    public var pitchingPower: Int // between 1 and 100
    var pitchingOverall: Int {
        (pitchingPower + pitchingControl) / 2
    }
    
    public enum Position: CaseIterable, Equatable {
        case pitcher
        case firstBase
        case secondBase
        case thirdBase
        case catcher
        case rightField
        case leftField
        case centerField
        case shortstop
        
        static var fielders: [Self] = allCases.filter({ $0 != .pitcher })
    }
    
    public static func random(with position: Position? = nil) -> Player {
        let age = Int.random(in: 21...39)
        let draftYear = 2023 - (age - 18)
        
        return .init(
            id: UUID(),
            firstName: mostCommonFirstNames.randomElement()!,
            lastName: mostCommonLastNames.randomElement()!,
            position: position ?? Position.allCases.randomElement()!,
            age: age,
            draftYear: draftYear,
            speed: Int.random(in: 1...99),
            contactPercentage: Int.random(in: 1...99),
            power: Int.random(in: 1...99),
            plateDiscipline: Int.random(in: 1...99),
            pitchingControl: Int.random(in: 1...99),
            pitchingPower: Int.random(in: 1...99)
        )
    }
    
    public static func generateRandomRoster(pitchingRotationCount: Int = 5) -> [Player] {
        var roster = (0..<5).map({ _ in random(with: .pitcher) })
        for position in Position.fielders {
            roster += (0..<2).map({ _ in random(with: position) })
        }
        
        while roster.count != 26 {
            roster.append(random())
        }
        
        return roster
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
        speed: 1,
        contactPercentage: Int.random(in: 1..<100),
        power: Int.random(in: 1..<100),
        plateDiscipline: Int.random(in: 1..<100),
        pitchingControl: Int.random(in: 1..<100),
        pitchingPower: Int.random(in: 1..<100)
    )
    
    static func empty(id: UUID = UUID()) -> Self {
        .init(
            id: id,
            firstName: "",
            lastName: "",
            position: .catcher,
            age: 1,
            draftYear: 1,
            speed: 1,
            contactPercentage: Int.random(in: 1..<100),
            power: Int.random(in: 1..<100),
            plateDiscipline: Int.random(in: 1..<75),
            pitchingControl: Int.random(in: 1..<100),
            pitchingPower: Int.random(in: 1..<100)
        )
    }
    
    static func emptyWith(
        id: UUID = UUID(),
        position: Position = .catcher,
        speed: Int = Int.random(in: 1..<100),
        contactPercentage: Int = Int.random(in: 1..<100),
        power: Int = Int.random(in: 1..<100),
        plateDiscipline: Int = Int.random(in: 1..<75)
    ) -> Self {
        .init(
            id: id,
            firstName: "",
            lastName: "",
            position: position,
            age: 1,
            draftYear: 1,
            speed: speed,
            contactPercentage: contactPercentage,
            power: power,
            plateDiscipline: plateDiscipline,
            pitchingControl: Int.random(in: 1..<100),
            pitchingPower: Int.random(in: 1..<100)
        )
    }
    
    static func emptyWith(
        id: UUID = UUID(),
        position: Position = .catcher,
        overallValue: Int = Int.random(in: 1..<100)
    ) -> Self {
        .init(
            id: id,
            firstName: "",
            lastName: "",
            position: position,
            age: 1,
            draftYear: 1,
            speed: overallValue,
            contactPercentage: overallValue,
            power: overallValue,
            plateDiscipline: overallValue,
            pitchingControl: Int.random(in: 1..<100),
            pitchingPower: Int.random(in: 1..<100)
        )
    }
    
    static func emptyPitcherWith(
        id: UUID = UUID(),
        pitchingControl: Int,
        pitchingPower: Int
    ) -> Self {
        .init(
            id: id,
            firstName: "",
            lastName: "",
            position: .pitcher,
            age: 1,
            draftYear: 1,
            speed: 1,
            contactPercentage: 1,
            power: 1,
            plateDiscipline: 1,
            pitchingControl: pitchingControl,
            pitchingPower: pitchingPower
        )
    }
}
