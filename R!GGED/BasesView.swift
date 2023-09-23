//
//  BasesView.swift
//  R!GGED
//
//  Created by Shyam Kumar on 8/6/23.
//

import SwiftUI

struct BasesView: View {
    var body: some View {
        HStack(spacing: 4) {
            VStack {
                Spacer()
                Rectangle()
                    .frame(width: 20, height: 20, alignment: .center)
                    .rotationEffect(.degrees(45))
                    .foregroundColor(.create(hex: "#FFE500"))
            }
            
            VStack {
                Rectangle()
                    .frame(width: 20, height: 20, alignment: .center)
                    .rotationEffect(.degrees(45))
                    .foregroundColor(.create(hex: "#FFE500"))
                Spacer()
            }
            
            VStack {
                Spacer()
                Rectangle()
                    .frame(width: 20, height: 20, alignment: .center)
                    .rotationEffect(.degrees(45))
                    .foregroundColor(.create(hex: "#D9D9D9"))
            }
        }
        .frame(maxHeight: 40)
    }
}

struct BasesView_Previews: PreviewProvider {
    static var previews: some View {
        BasesView()
    }
}
