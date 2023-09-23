//
//  Color.swift
//  R!GGED
//
//  Created by Shyam Kumar on 8/6/23.
//

import SwiftUI

extension Color {
    public static func create(hex: String) -> Self {
        guard let uiColor = UIColor(hexaRGB: hex) else { return .primary }
        return Color(uiColor: uiColor)
    }
}
