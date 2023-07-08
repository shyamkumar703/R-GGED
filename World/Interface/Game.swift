//
//  Game.swift
//  World
//
//  Created by Shyam Kumar on 6/30/23.
//

import Foundation

public struct Game: Codable {
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
    
    private var generateRandomPitch: () -> Pitch = generateRandomPitchLive
    private var batterResult: (Pitch, Player) -> Pitch.BatterResult? = batterResultLive(pitch:player:)
    
    private var homeTeamBattingOrder: NonEmptyCircularArray<Player>
    private var awayTeamBattingOrder: NonEmptyCircularArray<Player>
    private var homeTeamPitcher: Player
    private var awayTeamPitcher: Player
    
    public enum CodingKeys: String, CodingKey {
        case homeTeam
        case awayTeam
        case currentBatter
        case homeTeamScore
        case awayTeamScore
        case halfInning
        case inning
        case outs
        case firstBase
        case secondBase
        case thirdBase
        case currentBalls
        case currentStrikes
        case umpireGame
        case homeTeamPitcherPitchCount
        case awayTeamPitcherPitchCount
        case isGameOver
        case homeTeamBattingOrder
        case awayTeamBattingOrder
        case homeTeamPitcher
        case awayTeamPitcher
    }
    
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
        generateRandomPitch: @escaping () -> Pitch = generateRandomPitchLive,
        batterResult: @escaping (Pitch, Player) -> Pitch.BatterResult? = batterResultLive
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
        self.batterResult = batterResult
        
        self.homeTeamBattingOrder = .init(homeTeam.battingOrder)
        self.awayTeamBattingOrder = .init(awayTeam.battingOrder)
        self.currentBatter = self.awayTeamBattingOrder.getFirst()
        self.homeTeamPitcher = self.homeTeam.pitchingRotation.getFirst()
        self.awayTeamPitcher = self.awayTeam.pitchingRotation.getFirst()
    }
    
    public mutating func generatePitch() -> Pitch.PitchResult {
        incrementPitchCount()
        let pitch = generateRandomPitch()
        if let batterResult = batterResult(pitch, currentBatter) {
            handle(batterResult: batterResult)
            return .noCall(batterResult)
        } else {
            return .call(pitch)
        }
    }
    
    public mutating func makeCall(call: Pitch.Call, on pitch: Pitch? = nil) {
        switch call {
        case .strike:
            currentStrikes += 1
        case .ball:
            currentBalls += 1
        }
        
        if currentStrikes == 3 {
            incrementOuts()
        } else if currentBalls == 4 {
            executeWalk()
        }
        
        guard let pitch else { return }
        umpireGame.updateGrade(pitch: pitch, call: call, atBat: atBat)
    }
    
    public mutating func simulate() {
        while !isGameOver {
            let pitch = generatePitch()
            switch pitch {
            case .call(let pitch):
                makeCall(call: pitch.getCorrectCall())
            default:
                continue
            }
        }
    }
}

// MARK: - Utility functions
extension Game {
    private mutating func handle(batterResult: Pitch.BatterResult) {
        switch batterResult {
        case .single:
            if self.thirdBase != .empty {
                incrementScore()
                self.thirdBase = .empty
            }
            
            if self.secondBase != .empty {
                incrementScore()
                self.secondBase = .empty
            }
            
            if self.firstBase != .empty {
                self.secondBase = self.firstBase
            }
            
            self.firstBase = .init(
                playerOn: currentBatter,
                pitcherResponsible: currentPitcher
            )
        case .double:
            if self.thirdBase != .empty {
                incrementScore()
                self.thirdBase = .empty
            }
            
            if self.secondBase != .empty {
                incrementScore()
                self.secondBase = .empty
            }
            
            if self.firstBase != .empty {
                self.thirdBase = self.firstBase
                self.firstBase = .empty
            }
            
            self.secondBase = .init(
                playerOn: currentBatter,
                pitcherResponsible: currentPitcher
            )
        case .triple:
            if self.thirdBase != .empty {
                incrementScore()
                self.thirdBase = .empty
            }
            
            if self.secondBase != .empty {
                incrementScore()
                self.secondBase = .empty
            }
            
            if self.firstBase != .empty {
                incrementScore()
                self.firstBase = .empty
            }
            
            self.thirdBase = .init(
                playerOn: currentBatter,
                pitcherResponsible: currentPitcher
            )
        case .homeRun:
            let numberOfRunsToScore = [firstBase, secondBase, thirdBase].filter({ $0 != .empty }).count + 1
            incrementScore(by: numberOfRunsToScore)
        case .groundOut:
            handleGroundOut()
        case .flyOut:
            handleFlyOut()
        case .foul:
            currentStrikes = min(currentStrikes + 1, 2)
        case .swingAndMiss:
            makeCall(call: .strike)
        }
    }
    
    private mutating func handleFlyOut() {
        /*
         1 or less outs
         --------------
         Bases loaded -> Runner on third scores, runner on second to third, runner on first to second, add an out
         1st and 2nd -> Runner on 1st to 2nd, runner on 2nd to 3rd, add an out
         1st and 3rd -> Runner on 3rd scores, runner on 1st to 2nd, add an out
         2nd and 3rd -> Runner on 3rd scores, runner on 2nd to 3rd, add an out
         1st -> Runner on 1st to 2nd, add an out
         2nd -> Runner on 2nd to 3rd, add an out
         3rd -> Runner on 3rd scores, add an out
         */
        if outs != 2 {
            if firstBase != .empty && secondBase != .empty && thirdBase != .empty {
                self.thirdBase = self.secondBase
                self.secondBase = self.firstBase
                self.firstBase = .empty
                incrementOuts()
                incrementScore()
            } else if firstBase != .empty && secondBase != .empty {
                self.thirdBase = self.secondBase
                self.secondBase = self.firstBase
                self.firstBase = .empty
                incrementOuts()
            } else if firstBase != .empty && thirdBase != .empty {
                self.secondBase = self.firstBase
                self.firstBase = .empty
                self.thirdBase = .empty
                incrementScore()
                incrementOuts()
            } else if secondBase != .empty && thirdBase != .empty {
                self.thirdBase = self.secondBase
                self.secondBase = .empty
                incrementOuts()
                incrementScore()
            } else if firstBase != .empty {
                self.secondBase = self.firstBase
                self.firstBase = .empty
                incrementOuts()
            } else if secondBase != .empty {
                self.thirdBase = self.secondBase
                self.secondBase = .empty
                incrementOuts()
            } else if thirdBase != .empty {
                self.thirdBase = .empty
                incrementOuts()
                incrementScore()
            } else {
                incrementOuts()
            }
        }
    }
    
    private mutating func handleGroundOut() {
        /*
         Bases loaded one out -> 1 run scores and add 2 out
         1st and 2nd one out -> Runner on third and add 2 outs
         1st and 3rd one one out -> 1 run scores and add 2 outs
         2nd and 3rd one out -> 1 run scores, runner to 3rd, add 1 out
         1st and one out -> Add two outs
         2nd and one out -> Add one out
         3rd and one out -> Add one run and one out
         Bases empty and one out -> Add one out
         
         Two outs -> End inning
         */
        if outs != 2 {
            if firstBase != .empty && secondBase != .empty && thirdBase != .empty {
                self.thirdBase = self.secondBase
                self.secondBase = .empty
                self.firstBase = .empty
                if outs + 2 != 3 { incrementScore() }
                incrementOuts(by: 2)
            } else if firstBase != .empty && secondBase != .empty {
                self.thirdBase = self.secondBase
                self.secondBase = .empty
                self.firstBase = .empty
                incrementOuts(by: 2)
            } else if firstBase != .empty && thirdBase != .empty {
                if outs + 2 != 3 { incrementScore() }
                incrementOuts(by: 2)
            } else if secondBase != .empty && thirdBase != .empty {
                incrementScore()
                self.thirdBase = self.secondBase
                self.secondBase = .empty
                incrementOuts()
            } else if firstBase != .empty {
                incrementOuts(by: 2)
            } else if secondBase != .empty {
                incrementOuts()
                self.thirdBase = self.secondBase
                self.secondBase = .empty
            } else if thirdBase != .empty {
                incrementScore()
                incrementOuts()
            } else {
                // bases empty
                incrementOuts()
            }
        } else {
            // 2 outs
            incrementOuts()
        }
    }
    
    private mutating func incrementOuts(by amount: Int = 1) {
        outs += amount
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
        
        if self.inning > 9 {
            switch atBat {
            case .away:
                secondBase = .init(playerOn: awayTeamBattingOrder.getFirst())
            case .home:
                secondBase = .init(playerOn: homeTeamBattingOrder.getFirst())
            }
        }
        
        switch self.atBat {
        case .away:
            self.currentBatter = self.awayTeamBattingOrder.getFirst()
        case .home:
            self.currentBatter = self.homeTeamBattingOrder.getFirst()
        }
    }
    
    private mutating func incrementScore(by amount: Int = 1) {
        switch atBat {
        case .away: awayTeamScore += amount
        case .home: homeTeamScore += amount
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
        
        public enum BatterResult: Codable {
            case swingAndMiss
            case foul
            case single
            case double
            case triple
            case homeRun
            case groundOut
            case flyOut
        }
        
        public enum PitchResult {
            case noCall(BatterResult)
            case call(Pitch)
        }
        
        public func getCorrectCall() -> Call {
            let isPitchOutOfZoneHorizontal = x < -0.5 || x > 6.5
            let isPitchOutOfZoneVertical = y < -10.5 || y > 0.5
            
            if !isPitchOutOfZoneHorizontal && !isPitchOutOfZoneVertical {
                return .strike
            } else {
                return .ball
            }
        }
    }
    
    public struct UmpireGame: Codable {
        public var homeTeamGrade: Int
        public var awayTeamGrade: Int
        public var grade: Int
        
        public enum CodingKeys: String, CodingKey {
            case homeTeamGrade
            case awayTeamGrade
            case grade
        }
        
        public init(
            homeTeamGrade: Int = 100,
            awayTeamGrade: Int = 100,
            grade: Int = 100
        ) {
            self.homeTeamGrade = homeTeamGrade
            self.awayTeamGrade = awayTeamGrade
            self.grade = grade
        }
        
        static var new: UmpireGame = .init()
        
        mutating func updateGrade(pitch: Pitch, call: Pitch.Call, atBat: WhichTeam) {
            defer { grade = (homeTeamGrade + awayTeamGrade) / 2 }
            let isPitchOutOfZoneHorizontal = pitch.x < -0.5 || pitch.x > 6.5
            let isPitchOutOfZoneVertical = pitch.y < -10.5 || pitch.y > 0.5
            let isPitchABall = isPitchOutOfZoneVertical && isPitchOutOfZoneHorizontal
            if isPitchABall && call == .strike || !isPitchABall && call == .ball {
                // call is wrong
                switch atBat {
                case .away: awayTeamGrade = max(awayTeamGrade - 10, 0)
                case .home: homeTeamGrade = max(homeTeamGrade - 10, 0)
                }
            } else {
                // call is correct
                switch atBat {
                case .away: awayTeamGrade = min(awayTeamGrade + 2, 100)
                case .home: homeTeamGrade = min(homeTeamGrade + 2, 100)
                }
            }
        }
    }
    
    public struct Base: Codable, Equatable {
        var playerOn: Player?
        var pitcherResponsible: Player?
        
        static var empty: Self = .init()
        
        public enum CodingKeys: String, CodingKey {
            case playerOn
            case pitcherResponsible
        }
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
    
    public enum HalfInning: String, Codable {
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
            generateRandomPitch: generateRandomPitch,
            batterResult: { _, _ in nil }
        )
    }
    
    static var liveBatter: Self {
        .init(homeTeam: .empty, awayTeam: .empty)
    }
    
    static func mockFullCount(battingOrder: [Player], generateRandomPitch: @escaping () -> Pitch = generateRandomPitchLive) -> Self {
        .init(
            homeTeam: .empty,
            awayTeam: .emptyWith(battingOrder: battingOrder),
            currentBalls: 3,
            currentStrikes: 2,
            generateRandomPitch: generateRandomPitchLive,
            batterResult: { _, _ in nil }
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
            generateRandomPitch: generateRandomPitchLive,
            batterResult: { _, _ in nil }
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
            generateRandomPitch: generateRandomPitchLive,
            batterResult: { _, _ in nil }
        )
    }
    
    static func mockWith(
        first: Base = .empty,
        second: Base = .empty,
        third: Base = .empty,
        batter: Player = .empty(),
        pitcher: Player = .empty(),
        outs: Int = 0,
        batterResult: @escaping (Pitch, Player) -> Pitch.BatterResult? = { _, _ in nil }
    ) -> Self {
        .init(
            homeTeam: .emptyWith(pitchingRotation: [pitcher]),
            awayTeam: .emptyWith(battingOrder: [batter]),
            outs: outs,
            firstBase: first,
            secondBase: second,
            thirdBase: third,
            batterResult: batterResult
        )
    }
    
    static func mockWith(
        balls: Int,
        strikes: Int,
        batterResult: @escaping (Pitch, Player) -> Pitch.BatterResult? = { _, _ in nil }
    ) -> Self {
        .init(
            homeTeam: .empty,
            awayTeam: .empty,
            currentBalls: balls,
            currentStrikes: strikes,
            batterResult: batterResult
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
    
    static func batterResultLive(pitch: Pitch, player: Player) -> Pitch.BatterResult? {
        let isPlayerLookingToSwing = Int.random(in: 0...100) > 20
        guard isPlayerLookingToSwing else { return nil }
        
        let isPitchOutOfZoneHorizontal = pitch.x < -0.5 || pitch.x > 6.5
        let isPitchOutOfZoneVertical = pitch.y < -10.5 || pitch.y > 0.5
        if isPitchOutOfZoneHorizontal && isPitchOutOfZoneVertical {
            // pitch is a ball
            let doesPlayerSwing = (Double(player.plateDiscipline) * Double.random(in: 0...1)) > 0.5
            if doesPlayerSwing {
                return .swingAndMiss
            } else {
                return nil
            }
        }
        
        let contactValue = Double.random(in: 0...1) * Double(player.contactPercentage)
        if contactValue < 10 {
            return .foul
        }
        
        let powerAndContactValue = contactValue * (Double(player.power) / 100)
        
        switch powerAndContactValue {
        case 0..<15:
            return .groundOut
        case 15..<35:
            return [
                Pitch.BatterResult.flyOut,
                Pitch.BatterResult.single
            ].randomElement()
        case 35..<65:
            return [
                Pitch.BatterResult.flyOut,
                Pitch.BatterResult.single,
                Pitch.BatterResult.double
            ].randomElement()
        default:
            return [
                Pitch.BatterResult.flyOut,
                Pitch.BatterResult.single,
                Pitch.BatterResult.double,
                Pitch.BatterResult.triple,
                Pitch.BatterResult.homeRun
            ].randomElement()
        }
    }
}
