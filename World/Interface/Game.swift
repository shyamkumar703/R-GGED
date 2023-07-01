//
//  Game.swift
//  World
//
//  Created by Shyam Kumar on 6/30/23.
//

import Foundation

public struct Game {
    public var homeTeam: Team
    public var awayTeam: Team
    public var currentBatter: Player
    public var homeTeamScore: Int
    public var awayTeamScore: Int
    public var halfInning: HalfInning
    public var inning: Int
    public var outs: Int
    public var firstBase: Base
    public var secondBase: Base
    public var thirdBase: Base
    public var currentBalls: Int
    public var currentStrikes: Int
    public var umpireGame: UmpireGame
    public var homeTeamPitcherPitchCount = 0
    public var awayTeamPitcherPitchCount = 0
    public var isGameOver = false
    
    public var currentPitcher: Player {
        switch pitching {
        case .home: return homeTeamPitcher
        case .away: return awayTeamPitcher
        }
    }
    
    public var atBat: WhichTeam {
        switch halfInning {
        case .top:
            return .away
        case .bottom:
            return .home
        }
    }
    
    public var pitching: WhichTeam {
        atBat.not
    }
    
    private var generateRandomPitch: () -> Pitch
    private var homeTeamBattingOrder: NonEmptyCircularArray<Player>
    private var awayTeamBattingOrder: NonEmptyCircularArray<Player>
    private var homeTeamPitcher: Player
    private var awayTeamPitcher: Player
    
    init(
        homeTeam: Team,
        awayTeam: Team,
        homeTeamScore: Int = 0,
        awayTeamScore: Int = 0,
        halfInning: HalfInning = .top,
        inning: Int = 1,
        outs: Int = 0,
        firstBase: Base = .empty,
        secondBase: Base = .empty,
        thirdBase: Base = .empty,
        currentBalls: Int = 0,
        currentStrikes: Int = 0,
        umpireGame: UmpireGame = .new,
        generateRandomPitch: @escaping () -> Pitch
    ) {
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.homeTeamScore = homeTeamScore
        self.awayTeamScore = awayTeamScore
        self.halfInning = halfInning
        self.inning = inning
        self.outs = outs
        self.firstBase = firstBase
        self.secondBase = secondBase
        self.thirdBase = thirdBase
        self.currentBalls = currentBalls
        self.currentStrikes = currentStrikes
        self.umpireGame = umpireGame
        self.generateRandomPitch = generateRandomPitch
        
        self.homeTeamBattingOrder = .init(homeTeam.battingOrder)
        self.awayTeamBattingOrder = .init(awayTeam.battingOrder)
        self.currentBatter = self.awayTeamBattingOrder.getFirst()
        self.homeTeamPitcher = self.homeTeam.pitchingRotation.getFirst()
        self.awayTeamPitcher = self.awayTeam.pitchingRotation.getFirst()
    }
    
    public mutating func generatePitch() -> Pitch {
        incrementPitchCount()
        return generateRandomPitch()
    }
    
    public mutating func makeCall(call: Pitch.Call, on pitch: Pitch) {
        switch call {
        case .strike:
            currentStrikes += 1
        case .ball:
            currentBalls += 1
        }
        
        if currentStrikes == 3 {
            recordOut()
        } else if currentBalls == 4 {
            executeWalk()
        }
    }
}

// MARK: - Utility functions
extension Game {
    private mutating func recordOut() {
        outs += 1
        clearCount()
        
        if outs == 3 {
            changeInning()
            return
        }
        
        switch atBat {
        case .home:
            currentBatter = homeTeamBattingOrder.getFirst()
        case .away:
            currentBatter = awayTeamBattingOrder.getFirst()
        }
    }
    
    private mutating func executeWalk() {
        clearCount()
        self.firstBase = .init(
            playerOn: currentBatter,
            pitcherResponsible: currentPitcher
        )
        
        switch atBat {
        case .home:
            self.currentBatter = self.homeTeamBattingOrder.getFirst()
        case .away:
            self.currentBatter = self.awayTeamBattingOrder.getFirst()
        }
    }
    
    private mutating func changeInning() {
        self.outs = 0
        clearCount()
        clearBases()
        
        if self.halfInning == .bottom {
            if self.inning >= 9 && homeTeamScore != awayTeamScore {
                finishGame()
                return
            }
            self.inning += 1
        }
        
        if self.inning >= 9 && self.halfInning == .top && homeTeamScore > awayTeamScore {
            finishGame()
            return
        }
        
        self.halfInning = self.halfInning.not
        
        switch self.atBat {
        case .away: self.currentBatter = self.awayTeamBattingOrder.getFirst()
        case .home: self.currentBatter = self.homeTeamBattingOrder.getFirst()
        }
    }
    
    private mutating func finishGame() {
        isGameOver = true
    }
    
    private mutating func clearCount() {
        self.currentBalls = 0
        self.currentStrikes = 0
    }
    
    private mutating func clearBases() {
        self.firstBase = .empty
        self.secondBase = .empty
        self.thirdBase = .empty
    }
    
    private mutating func incrementPitchCount() {
        switch pitching {
        case .home: homeTeamPitcherPitchCount += 1
        case .away: awayTeamPitcherPitchCount += 1
        }
    }
}

extension Game {
    public struct Pitch {
        /*
         Strike zone is 6x8 (wxh)
         Origin is at topLeft, topRight
         Ball has a diameter of 1
         (x, y) is the center of the pitch
         x - - - - - ·
         |           |
         |           |
         |           |
         |           |
         |           |
         |           |
         · - - - - - ·
         */
        var x: Double
        var y: Double
        
        public enum Call {
            case strike
            case ball
        }
    }
    
    public struct UmpireGame {
        var correctCalls: Int
        var incorrectCalls: Int
        var homeTeamTilt: Double
        var awayTeamTilt: Double
        var umpireGrade: Double
        
        static var new: Self = .init(correctCalls: 0, incorrectCalls: 0, homeTeamTilt: 0.5, awayTeamTilt: 0.5, umpireGrade: 0.5)
    }
    
    public struct Base: Equatable {
        var playerOn: Player?
        var pitcherResponsible: Player?
        
        static var empty: Self = .init()
    }
    
    public enum WhichTeam {
        case home
        case away
        
        var not: Self {
            switch self {
            case .home: return .away
            case .away: return .home
            }
        }
    }
    
    public enum HalfInning {
        case top
        case bottom
        
        var not: Self {
            switch self {
            case .top: return .bottom
            case .bottom: return .top
            }
        }
    }
}

extension Game {
    static func mock(generateRandomPitch: @escaping () -> Pitch = generateRandomPitchLive) -> Self {
        .init(
            homeTeam: .empty,
            awayTeam: .empty,
            generateRandomPitch: generateRandomPitch
        )
    }
    
    static func mockFullCount(battingOrder: [Player], generateRandomPitch: @escaping () -> Pitch = generateRandomPitchLive) -> Self {
        .init(
            homeTeam: .empty,
            awayTeam: .emptyWith(battingOrder: battingOrder),
            currentBalls: 3,
            currentStrikes: 2,
            generateRandomPitch: generateRandomPitchLive
        )
    }
    
    static func mockFullCountAndTwoOuts(
        homeTeamBattingOrder: [Player],
        awayTeamBattingOrder: [Player]
    ) -> Self {
        .init(
            homeTeam: .emptyWith(battingOrder: homeTeamBattingOrder),
            awayTeam: .emptyWith(battingOrder: awayTeamBattingOrder),
            outs: 2,
            currentBalls: 3,
            currentStrikes: 2,
            generateRandomPitch: generateRandomPitchLive
        )
    }
    
    static func mockFullCountTwoOutsWith(half: HalfInning, inning: Int, homeTeamScore: Int, awayTeamScore: Int) -> Self {
        .init(
            homeTeam: .empty,
            awayTeam: .empty,
            homeTeamScore: homeTeamScore,
            awayTeamScore: awayTeamScore,
            halfInning: half,
            inning: inning,
            outs: 2,
            currentBalls: 3,
            currentStrikes: 2,
            generateRandomPitch: generateRandomPitchLive
        )
    }
}

// MARK: - Live
extension Game {
    static func generateRandomPitchLive() -> Pitch {
        let randomX = Double.random(in: -2...8)
        let randomY = Double.random(in: -10...2)
        return .init(x: randomX, y: randomY)
    }
}
