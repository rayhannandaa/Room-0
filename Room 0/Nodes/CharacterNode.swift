//
//  CharacterNode.swift
//  Room 0
//
//  Created by Rayhan Nanda on 06/09/26.
//

import SpriteKit

class CharacterNode: SKSpriteNode {
    
    private(set) var facing: ControlDirection = .down
    private let idleLoopKey = "idleLoop"
    
    init() {
        let initialTexture = SKTexture(imageNamed: "IdleOne")
        super.init(texture: initialTexture, color: .clear, size: initialTexture.size())
        anchorPoint = CGPoint(x: 0.5, y: 0)
        setIdle(direction: .down)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func frameByFrameAction(textures: [SKTexture], perFrame: TimeInterval) -> SKAction {
        var steps: [SKAction] = []
        for texture in textures {
            let setTexture = SKAction.run { [weak self] in
                guard let self = self else { return }
                self.texture = texture
                self.size = texture.size()
            }
            let wait = SKAction.wait(forDuration: perFrame)
            steps.append(SKAction.sequence([setTexture, wait]))
        }
        return SKAction.sequence(steps)
    }
    
    func setIdle(direction: ControlDirection) {
        facing = direction
        removeAction(forKey: idleLoopKey)
        
        let frames = CharacterAnimationConfig.frames(for: direction, state: .idle)
        let textures = frames.map { SKTexture(imageNamed: $0) }
        
        if textures.count > 1 {
            let loopAction = frameByFrameAction(textures: textures, perFrame: 0.5)
            run(SKAction.repeatForever(loopAction), withKey: idleLoopKey)
        } else {
            texture = textures.first
            size = textures.first?.size() ?? size
        }
    }
    
    func playWalk(direction: ControlDirection, stepDuration: TimeInterval, completion: @escaping () -> Void) {
        facing = direction
        removeAction(forKey: idleLoopKey)
        
        let frames = CharacterAnimationConfig.frames(for: direction, state: .walking)
        let textures = frames.map { SKTexture(imageNamed: $0) }
        let perFrame = stepDuration / Double(textures.count)
        
        let walkAction = frameByFrameAction(textures: textures, perFrame: perFrame)
        
        run(walkAction, completion: completion)
    }
    
    func playSleep() {
        removeAction(forKey: idleLoopKey)
        let textures = ["SleepOne", "SleepTwo"].map { SKTexture(imageNamed: $0) }
        let loopAction = frameByFrameAction(textures: textures, perFrame: 0.5)
        run(SKAction.repeatForever(loopAction), withKey: idleLoopKey)
    }

    func showSleepTransitionFrame() {
        removeAction(forKey: idleLoopKey)
        let transitionTexture = SKTexture(imageNamed: "SleepOne")
        texture = transitionTexture
        size = transitionTexture.size()
    }
    
}
