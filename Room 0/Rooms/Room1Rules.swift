//
//  Room1Rules.swift
//  Room 0
//

import CoreGraphics
import Foundation

enum Room1Rules {
    static let stepDistance: CGFloat = 50
    static let stepDuration: TimeInterval = 0.2

    static let sidePadding: CGFloat = 50
    static let bottomPadding: CGFloat = 0
    static let topPadding: CGFloat = 115.5

    static let interactionRadius: CGFloat = 90
    static let interactionRadiusByObject: [Room1ObjectID: CGFloat] = [
        .lamp: 140
    ]

    static let markerVerticalGap: CGFloat = 12
    static let markerZPosition: CGFloat = 20

    static let openingObjects: Set<Room1ObjectID> = [
        .floor,
        .walls,
        .shelf,
        .lamp,
        .matchbox
    ]

    static let blockingObjects: Set<Room1ObjectID> = [
        .shelf,
        .machine,
        .table,
        .chair,
        .tableTwo,
        .lockedDoor,
        .matchbox,
        .chalk,
        .doubleBottle,
        .vinegarBottle
    ]

    static let collisionPadding: [Room1ObjectID: CGFloat] = [
        .vinegarBottle: 5,
        .chair: 10
    ]

    static let openingMovementBounds = CGRect(
        x: 275,
        y: 200,
        width: 250,
        height: 450
    )

    static func wallBuffer(for direction: ControlDirection) -> CGFloat {
        switch direction {
        case .up: 15
        case .down: 15
        case .left: 50
        case .right: 50
        }
    }

    static func worldSize(for sceneSize: CGSize) -> CGSize {
        CGSize(
            width: sceneSize.width + sidePadding * 2,
            height: sceneSize.height + bottomPadding + topPadding
        )
    }
}
