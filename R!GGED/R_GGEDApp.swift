//
//  R_GGEDApp.swift
//  R!GGED
//
//  Created by Shyam Kumar on 6/30/23.
//

import SwiftUI
import World

@main
struct R_GGEDApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: .init(game: .fullMock))
        }
    }
}
