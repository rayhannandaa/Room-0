//
//  VisionOverlayNode.swift
//  Room 0
//
//  Created by Rayhan Nanda on 07/09/26.
//

import SpriteKit
import UIKit

class VisionOverlayNode: SKSpriteNode {

    private let frameHoldDuration: TimeInterval = 0.3
    private let breathingActionKey = "visionBreathing"
    private let expansionActionKey = "visionExpansion"
    private let overlayColor = UIColor(red: 218/255, green: 215/255, blue: 206/255, alpha: 1.0)
    private let canvasSize = CGSize(width: 1600, height: 1600)
    private let bandWidth: CGFloat = 75
    private let bandOpacity: CGFloat = 0.5
    private var restingHoleDiameter: CGFloat
    private var breathingTextures: [SKTexture] = []

    init(holeDiameter: CGFloat = 505) {
        restingHoleDiameter = holeDiameter

        let frameOne = VisionOverlayNode.makeMaskTexture(canvasSize: canvasSize, holeDiameter: holeDiameter + 20, bandWidth: bandWidth, bandOpacity: bandOpacity, color: overlayColor)
        let frameTwo = VisionOverlayNode.makeMaskTexture(canvasSize: canvasSize, holeDiameter: holeDiameter + 10, bandWidth: bandWidth, bandOpacity: bandOpacity, color: overlayColor)
        let frameThree = VisionOverlayNode.makeMaskTexture(canvasSize: canvasSize, holeDiameter: holeDiameter, bandWidth: bandWidth, bandOpacity: bandOpacity, color: overlayColor)

        super.init(texture: frameOne, color: .clear, size: canvasSize)
        self.blendMode = .alpha

        breathingTextures = [frameOne, frameTwo, frameThree]
        startBreathing(with: breathingTextures)
    }

    func expandVision(
        to holeDiameter: CGFloat = 505,
        duration: TimeInterval = 1.2,
        completion: @escaping () -> Void
    ) {
        removeAction(forKey: breathingActionKey)
        removeAction(forKey: expansionActionKey)

        setScale(1)

        let startingDiameter = restingHoleDiameter
        let endingDiameter = holeDiameter + 20
        let expansionScale = endingDiameter / startingDiameter
        let transitionBandWidth = bandWidth / expansionScale

        texture = Self.makeMaskTexture(
            canvasSize: canvasSize,
            holeDiameter: startingDiameter,
            bandWidth: transitionBandWidth,
            bandOpacity: bandOpacity,
            color: overlayColor
        )

        let expand = SKAction.scale(to: expansionScale, duration: duration)
        expand.timingMode = .easeInEaseOut

        let finish = SKAction.run { [weak self] in
            guard let self else { return }

            self.restingHoleDiameter = holeDiameter
            self.setScale(1)

            self.breathingTextures = self.makeBreathingTextures(holeDiameter: holeDiameter)
            self.texture = self.breathingTextures.first
            self.startBreathing(with: self.breathingTextures)
            completion()
        }

        run(
            .sequence([expand, finish]),
            withKey: expansionActionKey
        )
    }

    func prepareForMenuHandoff() {
        removeAction(forKey: breathingActionKey)
        removeAction(forKey: expansionActionKey)
        setScale(1)
        texture = breathingTextures.first
        isHidden = true
    }

    func resumeAfterMenuHandoff() {
        removeAction(forKey: breathingActionKey)
        removeAction(forKey: expansionActionKey)
        setScale(1)
        texture = breathingTextures.first
        isHidden = false
        startBreathing(with: breathingTextures)
    }

    private func makeBreathingTextures(holeDiameter: CGFloat) -> [SKTexture] {
        [
            Self.makeMaskTexture(canvasSize: canvasSize, holeDiameter: holeDiameter + 20, bandWidth: bandWidth, bandOpacity: bandOpacity, color: overlayColor),
            Self.makeMaskTexture(canvasSize: canvasSize, holeDiameter: holeDiameter + 10, bandWidth: bandWidth, bandOpacity: bandOpacity, color: overlayColor),
            Self.makeMaskTexture(canvasSize: canvasSize, holeDiameter: holeDiameter, bandWidth: bandWidth, bandOpacity: bandOpacity, color: overlayColor)
        ]
    }

    private func startBreathing(with textures: [SKTexture]) {
        let breathe = SKAction.animate(
            with: textures,
            timePerFrame: frameHoldDuration,
            resize: false,
            restore: false
        )
        run(SKAction.repeatForever(breathe), withKey: breathingActionKey)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func makeMaskTexture(
        canvasSize: CGSize,
        holeDiameter: CGFloat,
        bandWidth: CGFloat,
        bandOpacity: CGFloat,
        color: UIColor
    ) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
        let holeRadius = holeDiameter / 2
        let bandOuterRadius = holeRadius + bandWidth
        
        let image = renderer.image { ctx in
            let cg = ctx.cgContext

            cg.setBlendMode(.copy)
            
            // 100% dim — fills the whole canvas first.
            color.withAlphaComponent(1.0).setFill()
            cg.fill(CGRect(origin: .zero, size: canvasSize))
            
            // 50% dim band — outer edge sits bandWidth beyond the hole.
            color.withAlphaComponent(bandOpacity).setFill()
            cg.fillEllipse(in: CGRect(
                x: center.x - bandOuterRadius, y: center.y - bandOuterRadius,
                width: bandOuterRadius * 2, height: bandOuterRadius * 2
            ))
            
            // Fully clear center — the actual "vision" hole.
            UIColor.clear.setFill()
            cg.fillEllipse(in: CGRect(
                x: center.x - holeRadius, y: center.y - holeRadius,
                width: holeRadius * 2, height: holeRadius * 2
            ))
        }
        
        return SKTexture(image: image)
    }
}
