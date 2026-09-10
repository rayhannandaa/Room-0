//
//  MainMenuModel.swift
//  Room 0
//

import Foundation

struct MainMenuModel {
    enum PresentationPhase {
        case menu
        case dismissingMenu
        case movingCharacter
        case roomCovered
        case game
    }

    struct TransitionTiming {
        let menuDismissDuration: TimeInterval
        let backgroundFadeDuration: TimeInterval
        let characterMoveDuration: TimeInterval
        let roomLoadSettleDuration: TimeInterval
        let roomRevealDuration: TimeInterval
    }

    struct Option: Identifiable {
        let action: Action
        let title: String

        var id: Action { action }
    }

    enum Action: Hashable {
        case play
        case continueGame
    }

    let options: [Option]
    let transitionTiming: TransitionTiming

    static let initial = MainMenuModel(
        options: [
            Option(action: .play, title: "PLAY"),
            Option(action: .continueGame, title: "CONTINUE")
        ],
        transitionTiming: TransitionTiming(
            menuDismissDuration: 0.3,
            backgroundFadeDuration: 0.45,
            characterMoveDuration: 0.85,
            roomLoadSettleDuration: 0.15,
            roomRevealDuration: 0.7
        )
    )
}
