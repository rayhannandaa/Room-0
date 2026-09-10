//
//  CharacterAnimationConfig.swift
//  Room 0
//
//  Created by Rayhan Nanda on 06/09/26.
//

import Foundation

enum MovementState {
    case idle
    case walking
}

struct CharacterAnimationConfig {
    static func frames(for direction: ControlDirection, state: MovementState) -> [String] {
        switch (direction, state) {
        case (.down, .idle):    return ["IdleOne", "IdleTwo"]
        case (.down, .walking): return ["FrontRight", "FrontLeft"]
        case (.up, .idle):      return ["IdleBackOne", "IdleBackTwo"]
        case (.up, .walking):   return ["BackRight", "BackLeft"]
        case (.left, .idle):    return ["LeftOne"]
        case (.left, .walking): return ["LeftOne", "LeftTwo", "LeftThree"]
        case (.right, .idle):   return ["RightOne"]
        case (.right, .walking):return ["RightOne", "RightTwo", "RightThree"]
        }
    }
}
