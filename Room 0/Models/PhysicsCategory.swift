//
//  PhysicsCategory.swift
//  Room 0
//
//  Created by Rayhan Nanda on 07/09/26.
//

import CoreGraphics

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let wall: UInt32 = 0x1 << 0
    static let obstacle: UInt32 = 0x1 << 1
}
