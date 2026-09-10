//
//  SleepAnimationNode.swift
//  Room 0
//
//  Created by Rayhan Nanda on 09/09/26.
//

import SpriteKit
import SwiftUI

class SleepAnimationNode: SKNode {
    
    static let horizontalGapFromCharacter: CGFloat = 25
    
    private let fontSizes: [CGFloat] = [14, 20, 26]
    private let basePositions: [CGPoint] = [
        CGPoint(x: 0, y: 0),
        CGPoint(x: 18, y: 34),
        CGPoint(x: 40, y: 70)
    ]
    private let baseRotations: [CGFloat] = [-0.15, 0.1, -0.1]
    
    private let frameOffsets: [[CGPoint]] = [
        [CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 0)],
        [CGPoint(x: -2, y: 4), CGPoint(x: 3, y: 5), CGPoint(x: -3, y: 6)],
        [CGPoint(x: 2, y: 8), CGPoint(x: -3, y: 10), CGPoint(x: 3, y: 12)]
    ]
    private let frameRotationDeltas: [[CGFloat]] = [
        [0, 0, 0],
        [0.08, -0.06, 0.05],
        [-0.05, 0.09, -0.07]
    ]
    
    private let frameHoldDuration: TimeInterval = 0.4
    
    private var zNodes: [SKLabelNode] = []
    
    override init() {
        super.init()
        buildLabels()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildLabels() {
        for i in 0..<3 {
            let label = SKLabelNode(fontNamed: ShineTypewriterFont.postScriptName)
            label.text = "Z"
            label.fontSize = fontSizes[i]
            label.fontColor = .black
            label.horizontalAlignmentMode = .left
            label.verticalAlignmentMode = .center
            label.position = basePositions[i]
            label.zRotation = baseRotations[i]
            addChild(label)
            zNodes.append(label)
        }
    }
    
    func start() {
        removeAction(forKey: "zzzLoop")
        
        var frameSteps: [SKAction] = []
        for frameIndex in 0..<3 {
            let setFrame = SKAction.run { [weak self] in
                self?.showFrame(at: frameIndex)
            }
            let wait = SKAction.wait(forDuration: frameHoldDuration)
            frameSteps.append(SKAction.sequence([setFrame, wait]))
        }
        
        run(SKAction.repeatForever(SKAction.sequence(frameSteps)), withKey: "zzzLoop")
    }
    
    func stop() {
        removeAction(forKey: "zzzLoop")
    }

    func showTransitionFrame() {
        stop()
        showFrame(at: 0)
    }

    private func showFrame(at frameIndex: Int) {
        for (i, label) in zNodes.enumerated() {
            let offset = frameOffsets[frameIndex][i]
            let rotationDelta = frameRotationDeltas[frameIndex][i]
            label.position = CGPoint(
                x: basePositions[i].x + offset.x,
                y: basePositions[i].y + offset.y
            )
            label.zRotation = baseRotations[i] + rotationDelta
        }
    }
}

#Preview {
    let character = CharacterNode()
    character.playSleep()
    
    let zzz = SleepAnimationNode()
    zzz.position = CGPoint(
        x: -(character.size.width / 2) - SleepAnimationNode.horizontalGapFromCharacter,
        y: character.size.height * 0.6
    )
    character.addChild(zzz)
    zzz.start()
    
    let scene = SKScene(size: CGSize(width: 300, height: 300))
    scene.backgroundColor = SKColor(red: 218/255, green: 215/255, blue: 206/255, alpha: 1)
    character.position = CGPoint(x: 150, y: 100)
    scene.addChild(character)
    
    return SpriteView(scene: scene)
        .frame(width: 300, height: 300)
}
