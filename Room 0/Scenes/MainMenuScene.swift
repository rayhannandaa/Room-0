//
//  MainMenuScene.swift
//  Room 0
//

import SpriteKit

final class MainMenuScene: SKScene {
    private let character = CharacterNode()
    private let sleepAnimationNode = SleepAnimationNode()
    private var hasPreparedScene = false
    private var transitionTargetY: CGFloat?
    private var roomCharacterTarget: CGPoint?
    private var roomSleepAnimationTarget: CGPoint?
    private var pendingRoomMoveDuration: TimeInterval?
    private var pendingRoomWindowPoints: (character: CGPoint, sleepAnimation: CGPoint)?

    func setRoomHandoffTargets(
        characterWindowPoint: CGPoint,
        sleepAnimationWindowPoint: CGPoint
    ) {
        guard let view else {
            pendingRoomWindowPoints = (
                characterWindowPoint,
                sleepAnimationWindowPoint
            )
            return
        }

        let characterPointInMenuView = view.convert(characterWindowPoint, from: nil)
        roomCharacterTarget = convertPoint(fromView: characterPointInMenuView)

        let sleepPointInMenuView = view.convert(sleepAnimationWindowPoint, from: nil)
        roomSleepAnimationTarget = convertPoint(fromView: sleepPointInMenuView)

        if let pendingRoomMoveDuration {
            self.pendingRoomMoveDuration = nil
            moveSleepingCharacterToRoom(duration: pendingRoomMoveDuration)
        }
    }

    func moveSleepingCharacterToRoom(duration: TimeInterval) {
        guard let roomCharacterTarget,
              let roomSleepAnimationTarget
        else {
            pendingRoomMoveDuration = duration
            return
        }

        transitionTargetY = roomCharacterTarget.y
        character.removeAction(forKey: "menuCharacterMove")
        character.showSleepTransitionFrame()
        sleepAnimationNode.showTransitionFrame()

        let move = SKAction.move(
            to: roomCharacterTarget,
            duration: duration
        )
        move.timingMode = .easeInEaseOut
        character.run(move, withKey: "menuCharacterMove")

        let sleepTargetOffset = CGPoint(
            x: roomSleepAnimationTarget.x - roomCharacterTarget.x,
            y: roomSleepAnimationTarget.y - roomCharacterTarget.y
        )
        let moveSleepAnimation = SKAction.move(
            to: sleepTargetOffset,
            duration: duration
        )
        moveSleepAnimation.timingMode = .easeInEaseOut
        sleepAnimationNode.run(
            moveSleepAnimation,
            withKey: "menuSleepAnimationMove"
        )
    }

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        scaleMode = .resizeFill

        guard !hasPreparedScene else {
            layoutSleepingCharacter()
            return
        }

        hasPreparedScene = true
        prepareSleepingCharacter()

        if let pendingRoomWindowPoints {
            self.pendingRoomWindowPoints = nil
            setRoomHandoffTargets(
                characterWindowPoint: pendingRoomWindowPoints.character,
                sleepAnimationWindowPoint: pendingRoomWindowPoints.sleepAnimation
            )
        }
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        layoutSleepingCharacter()
    }

    private func prepareSleepingCharacter() {
        character.zPosition = 1
        addChild(character)
        character.playSleep()

        sleepAnimationNode.position = CGPoint(
            x: -(character.size.width / 2) - SleepAnimationNode.horizontalGapFromCharacter,
            y: character.size.height * 0.6
        )
        sleepAnimationNode.zPosition = 2
        character.addChild(sleepAnimationNode)
        sleepAnimationNode.start()

        layoutSleepingCharacter()
    }

    private func layoutSleepingCharacter() {
        character.position = CGPoint(
            x: size.width / 2,
            y: transitionTargetY ?? 70
        )
    }
}
