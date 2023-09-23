//
//  ContentView.swift
//  R!GGED
//
//  Created by Shyam Kumar on 6/30/23.
//

import SwiftUI
import World

class ContentViewModel: ObservableObject {
    var game: Game
    @Published var pitchResult: Game.Pitch.PitchResult?
    
    init(game: Game) {
        self.game = game
    }
    
    func startGame() {
        self.pitchResult = game.generatePitch()
    }
    
    func handlePitchResult(with call: Game.Pitch.Call? = nil) {
        guard let pitchResult else { return }
        switch pitchResult {
        case .call(let pitch):
            guard let call else { fatalError("Must make a call on pitch") }
            game.makeCall(call: call, on: pitch)
        case .noCall: fatalError("Cannot make a call on batted ball")
        }
    }
}

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    private var game: Game {
        viewModel.game
    }
    
    private var inningArrow: Image {
        switch game.halfInning {
        case .top: return Image(systemName: "arrowtriangle.up.fill")
        case .bottom: return Image(systemName: "arrowtriangle.up.fill")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack {
                        Text("\(game.awayTeamScore)")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                        Text("\(game.awayTeam.teamAbbreviation)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.create(hex: game.awayTeam.teamColorPrimary))
                    }
                    
                    Spacer()
                    
                    BasesView()
                    
                    Spacer()
                    
                    VStack {
                        Text("\(game.homeTeamScore)")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                        Text("\(game.homeTeam.teamAbbreviation)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.create(hex: game.homeTeam.teamColorPrimary))
                    }
                }
                .padding(.horizontal)
                
                ZStack {
                    HStack(spacing: 12) {
                        HStack(alignment: .center, spacing: 2) {
                            inningArrow
                                .foregroundColor(.create(hex: "#FFE500"))
                                .font(.system(.caption2, design: .rounded, weight: .regular))
                            Text("\(game.inning)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        
                        Text("\(game.outs) OUTS")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                        
                        Spacer()
                        
                        Text("P: \(game.awayTeamPitcherPitchCount)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    
                    Text("\(game.currentBalls) - \(game.currentStrikes)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .padding(.horizontal)
            }
            
            HStack {
                Text("AB: \(game.currentBatter.firstName) \(game.currentBatter.lastName)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))

                Spacer()

                Text("P: \(game.currentPitcher.firstName) \(game.currentPitcher.lastName)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal)
            
            HStack {
                Text("F UMPIRE GRADE")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.create(hex: "#DF0000"))
                Spacer()
            }
            .padding(.horizontal)
            
            if case .call(let pitch) = viewModel.pitchResult {
                Spacer()
                StrikeZoneView(pitch: pitch)
            }

            Spacer()
        }
        .onAppear { viewModel.startGame() }
        .preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: .init(game: .fullMock))
    }
}
