//
//  MarkerNode.swift
//  Room 0
//
//  Created by Rayhan Nanda on 09/09/26.
//

import SpriteKit

final class MarkerNode: SKSpriteNode {

    let objectName: String
    let dialog: BubbleDialogSequence

    private(set) var isRevealed = false

    private let floatDistance: CGFloat = 6
    private let floatDuration: TimeInterval = 0.6
    private let fadeDuration: TimeInterval = 0.2     

    private let floatKey = "markerFloat"
    private let fadeKey = "markerFade"

    init(objectName: String, dialog: BubbleDialogSequence) {
        self.objectName = objectName
        self.dialog = dialog

        let texture = SKTexture(imageNamed: "Marker")
        super.init(texture: texture, color: .clear, size: texture.size())

        alpha = 0
        startFloating()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func startFloating() {
        let up = SKAction.moveBy(x: 0, y: floatDistance, duration: floatDuration)
        up.timingMode = .easeInEaseOut
        let down = up.reversed()
        run(.repeatForever(.sequence([up, down])), withKey: floatKey)
    }

    func show() {
        guard !isRevealed else { return }
        isRevealed = true
        removeAction(forKey: fadeKey)
        run(SKAction.fadeIn(withDuration: fadeDuration), withKey: fadeKey)
    }

    func hide() {
        guard isRevealed else { return }
        isRevealed = false
        removeAction(forKey: fadeKey)
        run(SKAction.fadeOut(withDuration: fadeDuration), withKey: fadeKey)
    }
}
