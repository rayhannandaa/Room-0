//
//  ShineTypewriterFont.swift
//  Room 0
//
//  Created by Rayhan Nanda on 07/09/26.
//

import SwiftUI

enum ShineTypewriterFont {
    static let postScriptName = "Shine Typewriter"
    
    static func font(size: CGFloat) -> Font {
        return Font.custom(postScriptName, size: size)
    }
}
