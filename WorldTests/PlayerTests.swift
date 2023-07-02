//
//  PlayerTests.swift
//  WorldTests
//
//  Created by Shyam Kumar on 7/2/23.
//

@testable import World
import XCTest

final class PlayerTests: XCTestCase {
    func testGenerateRandomRoster_CreatesPositionPlayersCorrectly() {
        let sut = Player.generateRandomRoster(pitchingRotationCount: 5)
        XCTAssertEqual(sut.count, 26)
        XCTAssertGreaterThanOrEqual(sut.filter({ $0.position == .pitcher }).count, 5)
        for position in Player.Position.fielders {
            XCTAssertGreaterThanOrEqual(sut.filter({ $0.position == position }).count, 2)
        }
    }
    
    func testPositionStarter_HasHighestOverallRating() {
        let starter: Player = .emptyWith(
            position: .catcher,
            speed: 99,
            contactPercentage: 99,
            power: 99,
            plateDiscipline: 99
        )
        
        let sut: [Player] = [
            starter,
            .emptyWith(
                position: .catcher,
                speed: 1,
                contactPercentage: 1,
                power: 1,
                plateDiscipline: 1
            )
        ]
        
        XCTAssertEqual(starter, sut.starter(for: .catcher))
    }
    
    func testPitchingRotation_SortsCorrectly() {
        let pitcher1: Player = .emptyPitcherWith(pitchingControl: 99, pitchingPower: 99)
        let pitcher2: Player = .emptyPitcherWith(pitchingControl: 98, pitchingPower: 98)
        let pitcher3: Player = .emptyPitcherWith(pitchingControl: 3, pitchingPower: 3)
        XCTAssertEqual(
            [pitcher2, pitcher3, pitcher1].pitchingRotation(),
            NonEmptyCircularArray(pitcher1, pitcher2, pitcher3)
        )
    }
    
    func testBattingOrder_SortsCorrectly() {
        let first: Player = .emptyWith(
            position: .firstBase,
            overallValue: 93
        )
        
        let second: Player = .emptyWith(
            position: .secondBase,
            overallValue: 94
        )
        
        let third: Player = .emptyWith(
            position: .thirdBase,
            overallValue: 95
        )
        
        let fourth: Player = .emptyWith(
            position: .catcher,
            overallValue: 96
        )
        
        let fifth: Player = .emptyWith(
            position: .rightField,
            overallValue: 89
        )
        
        let sixth: Player = .emptyWith(
            position: .leftField,
            overallValue: 88
        )
        
        let seventh: Player = .emptyWith(
            position: .centerField,
            overallValue: 87
        )
        
        let eighth: Player = .emptyWith(
            position: .shortstop,
            overallValue: 86
        )
        
        let ninth: Player = .emptyWith(
            position: .firstBase,
            overallValue: 85
        )
        
        XCTAssertEqual(
            [second, third, fourth, fifth, first, sixth, seventh, eighth, ninth]
                .battingOrder(),
            [first, second, third, fourth, fifth, sixth, seventh, eighth, ninth]
        )
    }
}
