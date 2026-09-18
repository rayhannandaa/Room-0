//
//  Room1WorldController.swift
//  Room 0
//

import SpriteKit

final class Room1WorldController {
    private unowned let scene: SKScene
    private let config: RoomConfig

    private(set) var markers: [Room1ObjectID: MarkerNode] = [:]

    init(scene: SKScene, config: RoomConfig) {
        self.scene = scene
        self.config = config
    }

    func buildOpeningWorld() {
        for object in config.objects {
            guard let objectID = object.room1ObjectID,
                  Room1Rules.openingObjects.contains(objectID)
            else {
                continue
            }

            addObject(object, identifiedBy: objectID)
        }
    }

    func revealRemainingWorld(excluding collectedObjects: Set<Room1ObjectID>) {
        for object in config.objects {
            guard let objectID = object.room1ObjectID,
                  node(for: objectID) == nil,
                  !collectedObjects.contains(objectID)
            else {
                continue
            }

            addObject(object, identifiedBy: objectID)
        }
    }

    func configuration(for object: Room1ObjectID) -> RoomObjectConfig? {
        config.objects.first { $0.room1ObjectID == object }
    }

    func node(for object: Room1ObjectID) -> SKNode? {
        scene.childNode(withName: object.rawValue)
    }

    func marker(for object: Room1ObjectID) -> MarkerNode? {
        markers[object]
    }

    func removeMarker(for object: Room1ObjectID) {
        markers.removeValue(forKey: object)?.removeFromParent()
    }

    func removeObject(_ object: Room1ObjectID) {
        removeMarker(for: object)
        guard let node = node(for: object) else { return }
        node.physicsBody = nil
        node.removeFromParent()
    }

    private func addObject(
        _ object: RoomObjectConfig,
        identifiedBy objectID: Room1ObjectID
    ) {
        let node = SKSpriteNode(imageNamed: object.assetName)

        node.size = object.size
        node.position = CGPoint(
            x: object.position.x + Room1Rules.sidePadding,
            y: object.position.y + Room1Rules.bottomPadding
        )
        node.zPosition = object.zPosition
        node.name = objectID.rawValue

        if objectID == .walls {
            let physicsBody = SKPhysicsBody(
                edgeLoopFrom: WallBoundary.makePath()
            )
            physicsBody.isDynamic = false
            physicsBody.categoryBitMask = PhysicsCategory.wall
            node.physicsBody = physicsBody
        } else if Room1Rules.blockingObjects.contains(objectID) {
            let physicsBody = SKPhysicsBody(rectangleOf: object.size)
            physicsBody.isDynamic = false
            physicsBody.categoryBitMask = PhysicsCategory.obstacle
            physicsBody.collisionBitMask = PhysicsCategory.none
            physicsBody.contactTestBitMask = PhysicsCategory.none
            node.physicsBody = physicsBody
        }

        if object.isInteractable, let dialog = object.dialog {
            let marker = MarkerNode(
                objectName: objectID.rawValue,
                dialog: dialog
            )
            marker.position = CGPoint(
                x: 0,
                y: object.size.height / 2 + Room1Rules.markerVerticalGap
            )
            marker.zPosition = Room1Rules.markerZPosition
            node.addChild(marker)
            markers[objectID] = marker
        }

        scene.addChild(node)
    }
}
