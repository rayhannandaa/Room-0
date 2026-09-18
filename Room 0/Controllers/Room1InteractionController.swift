//
//  Room1InteractionController.swift
//  Room 0
//

import SpriteKit

final class Room1InteractionController {
    private let character: CharacterNode
    private let world: Room1WorldController

    init(character: CharacterNode, world: Room1WorldController) {
        self.character = character
        self.world = world
    }

    func updateMarkerVisibility(
        controlsEnabled: Bool,
        inventoryOpen: Bool,
        isUnlocked: (Room1ObjectID) -> Bool
    ) {
        for (objectID, marker) in world.markers {
            guard let objectNode = marker.parent else { continue }

            let radius = Room1Rules.interactionRadiusByObject[objectID]
                ?? Room1Rules.interactionRadius
            let distance = interactionDistance(to: objectNode)

            if controlsEnabled,
               !inventoryOpen,
               isUnlocked(objectID),
               distance <= radius {
                marker.show()
            } else {
                marker.hide()
            }
        }
    }

    func nearestRevealedObject() -> Room1ObjectID? {
        world.markers
            .filter { $0.value.isRevealed }
            .min { first, second in
                guard let firstObject = first.value.parent,
                      let secondObject = second.value.parent
                else {
                    return false
                }

                return interactionDistance(to: firstObject)
                    < interactionDistance(to: secondObject)
            }?
            .key
    }

    func revealedObject(
        at location: CGPoint,
        in scene: SKScene
    ) -> Room1ObjectID? {
        for node in scene.nodes(at: location) {
            guard let marker = node as? MarkerNode,
                  marker.isRevealed,
                  let objectID = Room1ObjectID(rawValue: marker.objectName)
            else {
                continue
            }

            return objectID
        }

        return nil
    }

    private func interactionDistance(to objectNode: SKNode) -> CGFloat {
        let objectFrame = objectNode.frame
        let horizontalDistance = max(
            objectFrame.minX - character.position.x,
            character.position.x - objectFrame.maxX,
            0
        )
        let verticalDistance = max(
            objectFrame.minY - character.position.y,
            character.position.y - objectFrame.maxY,
            0
        )

        return hypot(horizontalDistance, verticalDistance)
    }
}
