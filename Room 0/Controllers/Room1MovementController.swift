//
//  Room1MovementController.swift
//  Room 0
//

import CoreGraphics
import SpriteKit

final class Room1MovementController {
    private unowned let scene: SKScene
    private let input: InputBridge
    private let character: CharacterNode
    private let cameraNode: SKCameraNode
    private let world: Room1WorldController
    private let worldSize: CGSize

    private var isMoving = false

    init(
        scene: SKScene,
        input: InputBridge,
        character: CharacterNode,
        cameraNode: SKCameraNode,
        world: Room1WorldController,
        worldSize: CGSize
    ) {
        self.scene = scene
        self.input = input
        self.character = character
        self.cameraNode = cameraNode
        self.world = world
        self.worldSize = worldSize
    }

    func update(
        allowsMovement: Bool,
        allowsFullRoomExploration: Bool,
        inventoryOpen: Bool,
        collectedObjects: Set<Room1ObjectID>
    ) {
        guard allowsMovement,
              !inventoryOpen,
              !isMoving,
              let direction = input.pendingDirection ?? input.heldDirection
        else {
            return
        }

        input.pendingDirection = nil

        performStep(
            direction: direction,
            allowsFullRoomExploration: allowsFullRoomExploration,
            collectedObjects: collectedObjects
        )
    }

    func synchronizeCameraPosition() {
        cameraNode.position = clampedCameraPosition(for: character.position)
    }

    private func performStep(
        direction: ControlDirection,
        allowsFullRoomExploration: Bool,
        collectedObjects: Set<Room1ObjectID>
    ) {
        let unit: CGVector

        switch direction {
        case .up:
            unit = CGVector(dx: 0, dy: 1)
        case .down:
            unit = CGVector(dx: 0, dy: -1)
        case .left:
            unit = CGVector(dx: -1, dy: 0)
        case .right:
            unit = CGVector(dx: 1, dy: 0)
        }

        let fullDestination = CGPoint(
            x: character.position.x + unit.dx * Room1Rules.stepDistance,
            y: character.position.y + unit.dy * Room1Rules.stepDistance
        )
        let wallBuffer = Room1Rules.wallBuffer(for: direction)
        let bufferVector = CGVector(
            dx: unit.dx * wallBuffer,
            dy: unit.dy * wallBuffer
        )
        let bufferedFullCheck = CGPoint(
            x: fullDestination.x + bufferVector.dx,
            y: fullDestination.y + bufferVector.dy
        )

        if isPathClear(
            to: bufferedFullCheck,
            allowsFullRoomExploration: allowsFullRoomExploration,
            collectedObjects: collectedObjects
        ) {
            moveCharacter(to: fullDestination, direction: direction)
            return
        }

        let destination = furthestClearPosition(
            from: character.position,
            toward: fullDestination,
            bufferVector: bufferVector,
            allowsFullRoomExploration: allowsFullRoomExploration,
            collectedObjects: collectedObjects
        )

        guard destination != character.position else {
            character.setIdle(direction: direction)
            return
        }

        moveCharacter(to: destination, direction: direction)
    }

    private func moveCharacter(
        to destination: CGPoint,
        direction: ControlDirection
    ) {
        isMoving = true

        let cameraDestination = clampedCameraPosition(for: destination)

        character.playWalk(
            direction: direction,
            stepDuration: Room1Rules.stepDuration
        ) { [weak self] in
            guard let self else { return }
            self.isMoving = false

            if self.input.heldDirection != direction {
                self.character.setIdle(direction: direction)
            }
        }

        character.run(
            SKAction.move(
                to: destination,
                duration: Room1Rules.stepDuration
            )
        )

        cameraNode.run(
            SKAction.move(
                to: cameraDestination,
                duration: Room1Rules.stepDuration
            )
        )
    }

    private func furthestClearPosition(
        from start: CGPoint,
        toward end: CGPoint,
        bufferVector: CGVector,
        allowsFullRoomExploration: Bool,
        collectedObjects: Set<Room1ObjectID>
    ) -> CGPoint {
        func isClearWithBuffer(_ point: CGPoint) -> Bool {
            let buffered = CGPoint(
                x: point.x + bufferVector.dx,
                y: point.y + bufferVector.dy
            )

            return isPathClear(
                to: buffered,
                allowsFullRoomExploration: allowsFullRoomExploration,
                collectedObjects: collectedObjects
            )
        }

        if isClearWithBuffer(end) {
            return end
        }

        if !isClearWithBuffer(start) {
            return start
        }

        var low: CGFloat = 0
        var high: CGFloat = 1

        for _ in 0..<8 {
            let mid = (low + high) / 2
            let midPoint = CGPoint(
                x: start.x + (end.x - start.x) * mid,
                y: start.y + (end.y - start.y) * mid
            )

            if isClearWithBuffer(midPoint) {
                low = mid
            } else {
                high = mid
            }
        }

        return CGPoint(
            x: start.x + (end.x - start.x) * low,
            y: start.y + (end.y - start.y) * low
        )
    }

    private func isPathClear(
        to point: CGPoint,
        allowsFullRoomExploration: Bool,
        collectedObjects: Set<Room1ObjectID>
    ) -> Bool {
        if !allowsFullRoomExploration,
           !Room1Rules.openingMovementBounds.contains(point) {
            return false
        }

        if let wallsNode = world.node(for: .walls) {
            let localPoint = scene.convert(point, to: wallsNode)
            guard WallBoundary.makePath().contains(localPoint) else {
                return false
            }
        }

        for objectID in Room1Rules.blockingObjects {
            guard !collectedObjects.contains(objectID),
                  let objectNode = world.node(for: objectID)
            else {
                continue
            }

            let padding = Room1Rules.collisionPadding[objectID] ?? 0
            let hitFrame = objectNode.frame.insetBy(dx: -padding, dy: -padding)

            if hitFrame.contains(point) {
                return false
            }
        }

        return true
    }

    private func clampedCameraPosition(for target: CGPoint) -> CGPoint {
        let halfWidth = scene.size.width / 2
        let halfHeight = scene.size.height / 2
        let minX = min(halfWidth, worldSize.width - halfWidth)
        let maxX = max(halfWidth, worldSize.width - halfWidth)
        let minY = min(halfHeight, worldSize.height - halfHeight)
        let maxY = max(halfHeight, worldSize.height - halfHeight)

        return CGPoint(
            x: min(max(target.x, minX), maxX),
            y: min(max(target.y, minY), maxY)
        )
    }
}
