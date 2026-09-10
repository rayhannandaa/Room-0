//
//  ColorHexConverter.swift
//  Room 0
//
//  Created by Rayhan Nanda on 06/09/26.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)
        
        let a, r, g, b: UInt64
        switch hexString.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255,
                            (rgb >> 8) * 17,
                            (rgb >> 4 & 0xF) * 17,
                            (rgb & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255,
                            rgb >> 16,
                            rgb >> 8 & 0xFF,
                            rgb & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (rgb >> 24,
                            rgb >> 16 & 0xFF,
                            rgb >> 8 & 0xFF,
                            rgb & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0) // fallback: opaque black
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
