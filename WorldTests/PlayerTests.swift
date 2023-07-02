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
}
