//
//  StrikeZoneView.swift
//  R!GGED
//
//  Created by Shyam Kumar on 8/7/23.
//

import SwiftUI
import World

fileprivate var unitMultiplier: CGFloat = 40
fileprivate var strikeZoneWidth: CGFloat = 6 * unitMultiplier
fileprivate var strikeZoneHeight: CGFloat = 8 * unitMultiplier

struct StrikeZoneView: View {
    var pitch: Game.Pitch
    
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    private var spacerWidth: CGFloat {
        (screenWidth - strikeZoneWidth) / 2
    }
    
    private var xUnitInPoints: CGFloat {
        spacerWidth / 2
    }
    
    var body: some View {
        VStack {
            Spacer(minLength: unitMultiplier * 2)
            HStack {
                Spacer(minLength: unitMultiplier * 2)

                ZStack(alignment: .top) {
                    Rectangle()
                        .frame(width: strikeZoneWidth, height: strikeZoneHeight, alignment: .center)
                        .foregroundColor(.clear)
                        .border(.gray, width: 0.5)

                    Circle()
                       .frame(width: unitMultiplier, height: unitMultiplier)
                       .position(x: (pitch.x * unitMultiplier), y: pitch.y * -unitMultiplier)
                }

                Spacer(minLength: unitMultiplier * 2)
            }
            Spacer(minLength: unitMultiplier * 2)
        }
        .preferredColorScheme(.dark)
    }
}

struct StrikeZoneView_Previews: PreviewProvider {
    static var previews: some View {
        StrikeZoneView(pitch: .init(x: 8, y: 2))
    }
}
