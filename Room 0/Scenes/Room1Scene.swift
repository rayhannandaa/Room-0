import SpriteKit
import SwiftUI
import UIKit

class Room1Scene: SKScene {
    static let openingCharacterAnchorY: CGFloat = 210
    
    private let config: RoomConfig
    private let input: InputBridge
    private let dialogHandler: (BubbleDialogSequence, (() -> Void)?) -> Void
    private let itemCollectedHandler: (InventoryItem) -> Bool
    private let itemUseUnlockedHandler: () -> Void
    private let activeItemProvider: () -> InventoryItem?
    private let hasDiscoveredChalkVinegarReactionProvider: () -> Bool
    private let guidanceHandler: (GuidanceStep, (() -> Void)?) -> Void
    private let character = CharacterNode()
    private let cameraNode = SKCameraNode()
    private let sleepAnimationNode = SleepAnimationNode()

    private let visionOverlay = VisionOverlayNode(holeDiameter: 220)
    private var sequenceState: Room1SequenceState = .sleeping
    private var lastProcessedInteractTrigger = 0
    private var hasPreparedSceneContents = false
    private var usesMenuHandoff = false
    private var menuHandoffAlignment: ((CGPoint, CGPoint) -> Void)?
    private var pendingMenuHandoffReveal: (
        delay: TimeInterval,
        duration: TimeInterval,
        completion: () -> Void
    )?
    
    private let stepDistance: CGFloat = 50
    private let stepDuration: TimeInterval = 0.2
    private var isMoving = false
    
    private let sidePadding: CGFloat = 50
    private let bottomPadding: CGFloat = 0
    private let topPadding: CGFloat = 115.5
    
    private let topWallBuffer: CGFloat = 15
    private let bottomWallBuffer: CGFloat = 15
    private let leftWallBuffer: CGFloat = 50
    private let rightWallBuffer: CGFloat = 50

    private let blockingObjectNames: Set<String> = [
        "Shelf",
        "Machine",
        "Table",
        "Chair",
        "TableTwo",
        "LockDoor",
        "Matchbox",
        "Chalk",
        "DoubleBottle",
        "VinegarBottle"
    ]
    
    private let extraCollisionPadding: [String: CGFloat] = [
        "VinegarBottle": 5,
        "Chair": 10
    ]
    
    private let worldSize: CGSize
    
    private var markers: [String: MarkerNode] = [:]
    private var collectedObjectNames: Set<String> = []
    private var hasExaminedJournal = false
    private var hasExaminedLockedDoor = false
    private var isMaterialsDialoguePending = false
    private var isLockedDoorCleared = false
    private let interactionRadius: CGFloat = 90
    private let interactionRadiusByObject: [String: CGFloat] = [
        "Lamp": 140
    ]
    private let markerVerticalGap: CGFloat = 12
    private let markerZPosition: CGFloat = 20      

    private let openingObjectNames: Set<String> = [
        "Floor",
        "Walls",
        "Shelf",
        "Lamp",
        "Matchbox"
    ]

    private let openingMovementBounds = CGRect(
        x: 275,
        y: 200,
        width: 250,
        height: 450
    )

    init(
        config: RoomConfig,
        input: InputBridge,
        dialogHandler: @escaping (BubbleDialogSequence, (() -> Void)?) -> Void,
        itemCollectedHandler: @escaping (InventoryItem) -> Bool,
        itemUseUnlockedHandler: @escaping () -> Void,
        activeItemProvider: @escaping () -> InventoryItem?,
        hasDiscoveredChalkVinegarReactionProvider: @escaping () -> Bool,
        guidanceHandler: @escaping (GuidanceStep, (() -> Void)?) -> Void
    ) {
        self.config = config
        self.input = input
        self.dialogHandler = dialogHandler
        self.itemCollectedHandler = itemCollectedHandler
        self.itemUseUnlockedHandler = itemUseUnlockedHandler
        self.activeItemProvider = activeItemProvider
        self.hasDiscoveredChalkVinegarReactionProvider = hasDiscoveredChalkVinegarReactionProvider
        self.guidanceHandler = guidanceHandler
        
        self.worldSize = CGSize(
            width: config.sceneSize.width + (50 * 2),
            height: config.sceneSize.height + 0 + 115.5
        )
        
        super.init(size: config.sceneSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func prepareForPresentation(
        usesMenuHandoff: Bool = false,
        menuHandoffAlignment: ((CGPoint, CGPoint) -> Void)? = nil
    ) {
        self.usesMenuHandoff = usesMenuHandoff
        self.menuHandoffAlignment = menuHandoffAlignment
        prepareSceneContents()

        if usesMenuHandoff {
            character.showSleepTransitionFrame()
            sleepAnimationNode.showTransitionFrame()
            visionOverlay.prepareForMenuHandoff()
        }
    }

    func resumeOpeningAnimationAfterMenuHandoff() {
        guard usesMenuHandoff else { return }
        usesMenuHandoff = false
        character.playSleep()
        sleepAnimationNode.start()
    }

    func beginMenuHandoffReveal(
        after delay: TimeInterval,
        duration: TimeInterval,
        completion: @escaping () -> Void
    ) {
        guard let view else {
            pendingMenuHandoffReveal = (delay, duration, completion)
            return
        }

        presentMenuHandoffReveal(
            in: view,
            after: delay,
            duration: duration,
            completion: completion
        )
    }
    
    
    override func didMove(to view: SKView) {
        self.size = view.bounds.size
        self.scaleMode = .aspectFill
        self.backgroundColor = .clear
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)

        prepareSceneContents()

        if cameraNode.parent == nil {
            setupCamera()
        }

        if usesMenuHandoff {
            view.isPaused = true
            reportMenuHandoffAlignment(in: view)
        }

        if let pendingMenuHandoffReveal {
            self.pendingMenuHandoffReveal = nil
            presentMenuHandoffReveal(
                in: view,
                after: pendingMenuHandoffReveal.delay,
                duration: pendingMenuHandoffReveal.duration,
                completion: pendingMenuHandoffReveal.completion
            )
        }
    }

    private func presentMenuHandoffReveal(
        in view: SKView,
        after delay: TimeInterval,
        duration: TimeInterval,
        completion: @escaping () -> Void
    ) {
        view.isPaused = false

        let visionCenterInScene = visionOverlay.convert(CGPoint.zero, to: self)
        let visionCenterInView = convertPoint(toView: visionCenterInScene)

        let revealView = RoomHandoffRevealView(frame: view.bounds)
        revealView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        revealView.isUserInteractionEnabled = false
        revealView.configure(center: visionCenterInView)
        view.addSubview(revealView)

        revealView.scheduleReveal(
            after: delay,
            duration: duration
        ) { [weak self, weak revealView] in
            self?.visionOverlay.resumeAfterMenuHandoff()
            revealView?.removeFromSuperview()
            completion()
        }
    }

    private func reportMenuHandoffAlignment(in view: SKView) {
        DispatchQueue.main.async { [weak self, weak view] in
            guard let self, let view else { return }

            let anchorInScene = self.character.convert(CGPoint.zero, to: self)
            let anchorInView = self.convertPoint(toView: anchorInScene)
            let anchorInWindow = view.convert(anchorInView, to: nil)

            let sleepAnchorInScene = self.sleepAnimationNode.convert(CGPoint.zero, to: self)
            let sleepAnchorInView = self.convertPoint(toView: sleepAnchorInScene)
            let sleepAnchorInWindow = view.convert(sleepAnchorInView, to: nil)

            self.menuHandoffAlignment?(anchorInWindow, sleepAnchorInWindow)
        }
    }

    private func prepareSceneContents() {
        guard !hasPreparedSceneContents else { return }
        hasPreparedSceneContents = true

        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        setupObjects()
        setupCharacter()
        prepareOpeningSequence()
    }
    
    private func setupObjects() {
        for obj in config.objects where openingObjectNames.contains(obj.name) {
            addObject(obj)
        }
    }

    private func addObject(_ obj: RoomObjectConfig) {
        let node = SKSpriteNode(imageNamed: obj.assetName)

        node.size = obj.size
        node.position = CGPoint(
            x: obj.position.x + sidePadding,
            y: obj.position.y + bottomPadding
        )
        node.zPosition = obj.zPosition
        node.name = obj.name

        if obj.name == "Walls" {
            let physicsBody = SKPhysicsBody(
                edgeLoopFrom: WallBoundary.makePath()
            )

            physicsBody.isDynamic = false
            physicsBody.categoryBitMask = PhysicsCategory.wall
            node.physicsBody = physicsBody
        } else if blockingObjectNames.contains(obj.name) {
            let physicsBody = SKPhysicsBody(rectangleOf: obj.size)
            physicsBody.isDynamic = false
            physicsBody.categoryBitMask = PhysicsCategory.obstacle
            physicsBody.collisionBitMask = PhysicsCategory.none
            physicsBody.contactTestBitMask = PhysicsCategory.none
            node.physicsBody = physicsBody
        }

        if obj.isInteractable, let dialog = obj.dialog {
            let marker = MarkerNode(objectName: obj.name, dialog: dialog)
            marker.position = CGPoint(x: 0, y: obj.size.height / 2 + markerVerticalGap)
            marker.zPosition = markerZPosition
            node.addChild(marker)
            markers[obj.name] = marker
        }

        addChild(node)
    }

    private func revealRemainingObjects() {
        for obj in config.objects
        where childNode(withName: obj.name) == nil
            && !collectedObjectNames.contains(obj.name) {
            addObject(obj)
        }
    }
    
    private func setupCharacter() {
        character.position = CGPoint(
            x: 375 + sidePadding,
            y: Self.openingCharacterAnchorY + bottomPadding
        )
        
        character.zPosition = 2.5
        
        addChild(character)
        
        visionOverlay.position = CGPoint(x: 0, y: character.size.height / 2)
        visionOverlay.zPosition = 10
        character.addChild(visionOverlay)
    }
    
    private func setupCamera() {
        addChild(cameraNode)
        
        self.camera = cameraNode
        
        cameraNode.position = clampedCameraPosition(
            for: character.position
        )
    }
    
    override func update(_ currentTime: TimeInterval) {
        updateMarkerVisibility()

        if sequenceState == .sleeping, !input.isOpeningSequencePending {
            startOpeningDialogue()
            return
        }

        if input.interactTrigger != lastProcessedInteractTrigger {
            lastProcessedInteractTrigger = input.interactTrigger
            handleInteraction()
        }

        if sequenceState == .matchboxCollected, !input.isInventoryOpen {
            startInventoryGuidance()
            return
        }

        if isMaterialsDialoguePending, !input.isInventoryOpen {
            presentCollectedMaterialsDialogue()
            return
        }

        guard sequenceState == .searchingForMatchbox
                || sequenceState == .searchingForLamp
                || sequenceState == .lampDiscovered
                || sequenceState == .lampLit,
              !input.isInventoryOpen
        else {
            return
        }

        guard !isMoving,
              let direction = input.pendingDirection
        else {
            return
        }
        
        input.pendingDirection = nil
        
        performStep(direction: direction)
    }
    
    private func updateMarkerVisibility() {
        for marker in markers.values {
            guard let objectNode = marker.parent else { continue }

            let radius = interactionRadiusByObject[marker.objectName] ?? interactionRadius
            let distance = interactionDistance(to: objectNode)
            
            if input.controlsEnabled,
               !input.isInventoryOpen,
               isMarkerUnlocked(marker),
               distance <= radius {
                marker.show()
            } else {
                marker.hide()
            }
        }
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

    private func isMarkerUnlocked(_ marker: MarkerNode) -> Bool {
        switch marker.objectName {
        case "Matchbox":
            return sequenceState == .searchingForMatchbox
        case "Lamp":
            return sequenceState == .searchingForLamp || sequenceState == .lampDiscovered
        default:
            return true
        }
    }
    
    private func handleInteraction() {
        guard input.controlsEnabled, !input.isInventoryOpen else { return }

        let nearestMarker = markers.values
            .filter(\.isRevealed)
            .min { first, second in
                guard let firstObject = first.parent,
                      let secondObject = second.parent
                else {
                    return false
                }

                let firstDistance = interactionDistance(to: firstObject)
                let secondDistance = interactionDistance(to: secondObject)
                return firstDistance < secondDistance
            }

        guard let marker = nearestMarker,
              let objectNode = marker.parent,
              let objectName = objectNode.name,
              let objectConfig = config.objects.first(where: { $0.name == objectName })
        else {
            return
        }

        if objectName == "Lamp",
           sequenceState == .lampDiscovered,
           activeItemProvider()?.name == "Matchbox" {
            startLampLightingSequence()
            return
        }

        if objectName == "LockDoor",
           !isLockedDoorCleared,
           hasDiscoveredChalkVinegarReactionProvider(),
           activeItemProvider()?.name == "Vinegar" {
            startDoorDissolvingSequence(doorNode: objectNode)
            return
        }

        if let item = objectConfig.collectibleItem {
            guard itemCollectedHandler(item) else { return }

            collectedObjectNames.insert(objectName)
            markers.removeValue(forKey: objectName)
            objectNode.physicsBody = nil
            objectNode.removeFromParent()

            if objectName == "Chalk" || objectName == "VinegarBottle" {
                let hasBothMaterials = collectedObjectNames.contains("Chalk")
                    && collectedObjectNames.contains("VinegarBottle")
                isMaterialsDialoguePending = hasBothMaterials
            }

            if objectName == "Matchbox" {
                sequenceState = .matchboxCollected
            }
            return
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard input.controlsEnabled,
              !input.isInventoryOpen,
              let touch = touches.first
        else {
            return
        }

        let location = touch.location(in: self)

        for node in nodes(at: location) {
            guard let marker = node as? MarkerNode, marker.isRevealed else {
                continue
            }

            let dialog = examinationDialog(
                for: marker.objectName,
                fallback: marker.dialog
            ) ?? marker.dialog

            presentExaminationDialog(dialog) { [weak self] in
                self?.handleCompletedExamination(of: marker.objectName)
            }
            return
        }
    }

    private func presentExaminationDialog(
        _ dialog: BubbleDialogSequence,
        completion: (() -> Void)? = nil
    ) {
        input.controlsEnabled = false
        dialogHandler(dialog) { [weak self] in
            guard let self else { return }
            self.input.controlsEnabled = true
            completion?()
        }
    }

    private func handleCompletedExamination(of objectName: String) {
        switch objectName {
        case "Matchbox" where sequenceState == .searchingForMatchbox:
            guidanceHandler(.pickupObject, nil)
        case "Lamp" where sequenceState == .searchingForLamp:
            sequenceState = .lampDiscovered
            itemUseUnlockedHandler()
            guidanceHandler(.openInventoryForItem, nil)
        case "Journal":
            hasExaminedJournal = true
        case "LockDoor":
            hasExaminedLockedDoor = true
        default:
            break
        }
    }

    private func examinationDialog(
        for objectName: String,
        fallback: BubbleDialogSequence?
    ) -> BubbleDialogSequence? {
        guard objectName == "LockDoor",
              hasDiscoveredChalkVinegarReactionProvider()
        else {
            return fallback
        }

        if hasExaminedLockedDoor {
            return BubbleDialogSequence(lines: [
                BubbleDialogLine(speakerName: "Young Man", text: "That white buildup around the mechanism..."),
                BubbleDialogLine(speakerName: "Young Man", text: "If it contains calcium carbonate, the vinegar should break it down."),
                BubbleDialogLine(speakerName: "Young Man", text: "I should try using the vinegar on the door.")
            ])
        }

        return BubbleDialogSequence(lines: [
            BubbleDialogLine(speakerName: "Young Man", text: "The door is locked, and this white buildup is jamming the mechanism."),
            BubbleDialogLine(speakerName: "Young Man", text: "It looks like the chalk I tested."),
            BubbleDialogLine(speakerName: "Young Man", text: "The vinegar should break it down.")
        ])
    }

    private func presentCollectedMaterialsDialogue() {
        isMaterialsDialoguePending = false
        input.controlsEnabled = false
        input.pendingDirection = nil

        let openingLine: String
        if hasExaminedJournal {
            openingLine = "The chalk and vinegar—these must be the materials mentioned in the journal."
        } else {
            openingLine = "Chalk and vinegar..."
        }

        let sequence = BubbleDialogSequence(lines: [
            BubbleDialogLine(speakerName: "Young Man", text: openingLine),
            BubbleDialogLine(speakerName: "Young Man", text: "These can't have been left here together by accident."),
            BubbleDialogLine(speakerName: "Young Man", text: "I should mix a small amount and see how they react.")
        ])

        dialogHandler(sequence) { [weak self] in
            guard let self else { return }
            self.input.controlsEnabled = true
            self.guidanceHandler(.openInventoryForCombination, nil)
        }
    }

    private func prepareOpeningSequence() {
        input.controlsEnabled = false
        character.playSleep()

        sleepAnimationNode.position = CGPoint(
            x: -(character.size.width / 2) - SleepAnimationNode.horizontalGapFromCharacter,
            y: character.size.height * 0.6
        )
        sleepAnimationNode.zPosition = 11
        character.addChild(sleepAnimationNode)
        sleepAnimationNode.start()
    }

    private func startOpeningDialogue() {
        sequenceState = .sleepingDialogue

        let sleepingSequence = BubbleDialogSequence(lines: [
            BubbleDialogLine(text: "..."),
            BubbleDialogLine(text: "..."),
            BubbleDialogLine(text: "...")
        ])

        dialogHandler(sleepingSequence) { [weak self] in
            self?.startWakingDialogue()
        }
    }

    private func startWakingDialogue() {
        sequenceState = .wakingDialogue
        sleepAnimationNode.stop()
        sleepAnimationNode.removeFromParent()
        character.setIdle(direction: .down)

        let wakingSequence = BubbleDialogSequence(lines: [
            BubbleDialogLine(speakerName: "Young Man", text: "Where... am I?"),
            BubbleDialogLine(speakerName: "Young Man", text: "What is this place?"),
            BubbleDialogLine(speakerName: "Young Man", text: "It's too dark. I can barely see anything."),
            BubbleDialogLine(speakerName: "Young Man", text: "I need to find something that can make a light.")
        ])

        dialogHandler(wakingSequence) { [weak self] in
            guard let self else { return }
            self.sequenceState = .searchingForMatchbox
            self.input.controlsEnabled = true
        }
    }

    private func startPostMatchboxDialogue() {
        sequenceState = .postMatchboxDialogue
        input.controlsEnabled = false

        let sequence = BubbleDialogSequence(lines: [
            BubbleDialogLine(speakerName: "Young Man", text: "Matches... but they won't help on their own."),
            BubbleDialogLine(speakerName: "Young Man", text: "I need to find something nearby that I can light.")
        ])

        dialogHandler(sequence) { [weak self] in
            guard let self else { return }
            self.sequenceState = .searchingForLamp
            self.input.controlsEnabled = true
        }
    }

    private func startInventoryGuidance() {
        sequenceState = .inventoryGuidance
        input.pendingDirection = nil
        guidanceHandler(.inventoryInformation) { [weak self] in
            self?.startPostMatchboxDialogue()
        }
    }

    private func startLampLightingSequence() {
        sequenceState = .lampLit
        input.controlsEnabled = false
        input.pendingDirection = nil

        if let lampMarker = markers.removeValue(forKey: "Lamp") {
            lampMarker.removeFromParent()
        }

        revealRemainingObjects()

        visionOverlay.expandVision(to: 505) { [weak self] in
            self?.presentRoomRevealedDialogue()
        }
    }

    private func presentRoomRevealedDialogue() {
        let sequence = BubbleDialogSequence(lines: [
            BubbleDialogLine(speakerName: "Young Man", text: "The lamp is lit. I can finally see."),
            BubbleDialogLine(speakerName: "Young Man", text: "This room... something about it feels wrong."),
            BubbleDialogLine(speakerName: "Young Man", text: "I need to explore this place and find a way out.")
        ])

        dialogHandler(sequence) { [weak self] in
            self?.input.controlsEnabled = true
        }
    }

    private func startDoorDissolvingSequence(doorNode: SKNode) {
        input.controlsEnabled = false
        input.pendingDirection = nil

        if let doorMarker = markers.removeValue(forKey: "LockDoor") {
            doorMarker.removeFromParent()
        }

        doorNode.physicsBody = nil

        let fadeOut = SKAction.fadeOut(withDuration: 0.4)
        fadeOut.timingMode = .easeOut

        doorNode.run(.sequence([
            fadeOut,
            .run { [weak self, weak doorNode] in
                guard let self else { return }

                doorNode?.removeFromParent()
                self.isLockedDoorCleared = true
                self.presentDoorClearedDialogue()
            }
        ]))
    }

    private func presentDoorClearedDialogue() {
        let sequence = BubbleDialogSequence(lines: [
            BubbleDialogLine(speakerName: "Young Man", text: "It worked. The vinegar dissolved the buildup."),
            BubbleDialogLine(speakerName: "Young Man", text: "The mechanism is free, and the way is open."),
            BubbleDialogLine(speakerName: "Young Man", text: "Whatever is beyond this door... maybe it will tell me why I'm here.")
        ])

        dialogHandler(sequence) { [weak self] in
            self?.input.controlsEnabled = true
        }
    }
    
    private func performStep(direction: ControlDirection) {
        let unit: CGVector
        let wallBuffer: CGFloat
        
        switch direction {
        case .up:
            unit = CGVector(dx: 0, dy: 1)
            wallBuffer = topWallBuffer
            
        case .down:
            unit = CGVector(dx: 0, dy: -1)
            wallBuffer = bottomWallBuffer
            
        case .left:
            unit = CGVector(dx: -1, dy: 0)
            wallBuffer = leftWallBuffer
            
        case .right:
            unit = CGVector(dx: 1, dy: 0)
            wallBuffer = rightWallBuffer
        }
        
        let fullDestination = CGPoint(
            x: character.position.x + unit.dx * stepDistance,
            y: character.position.y + unit.dy * stepDistance
        )
        
        let bufferVector = CGVector(
            dx: unit.dx * wallBuffer,
            dy: unit.dy * wallBuffer
        )
        
        let bufferedFullCheck = CGPoint(
            x: fullDestination.x + bufferVector.dx,
            y: fullDestination.y + bufferVector.dy
        )
        
        if isPathClear(to: bufferedFullCheck) {
            moveCharacter(
                to: fullDestination,
                direction: direction
            )
            
            return
        }
        
        let destination = furthestClearPosition(
            from: character.position,
            toward: fullDestination,
            bufferVector: bufferVector
        )
        
        guard destination != character.position else {
            character.setIdle(direction: direction)
            return
        }
        
        moveCharacter(
            to: destination,
            direction: direction
        )
    }
    
    private func moveCharacter(
        to destination: CGPoint,
        direction: ControlDirection
    ) {
        isMoving = true
        
        let cameraDestination = clampedCameraPosition(
            for: destination
        )
        
        character.playWalk(
            direction: direction,
            stepDuration: stepDuration
        ) { [weak self] in
            self?.isMoving = false
        }
        
        character.run(
            SKAction.move(
                to: destination,
                duration: stepDuration
            )
        )
        
        cameraNode.run(
            SKAction.move(
                to: cameraDestination,
                duration: stepDuration
            )
        )
    }
    
    private func furthestClearPosition(
        from start: CGPoint,
        toward end: CGPoint,
        bufferVector: CGVector
    ) -> CGPoint {
        
        func isClearWithBuffer(_ point: CGPoint) -> Bool {
            let buffered = CGPoint(
                x: point.x + bufferVector.dx,
                y: point.y + bufferVector.dy
            )
            
            return isPathClear(to: buffered)
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
    
    private func isPathClear(to point: CGPoint) -> Bool {
        if sequenceState != .lampLit,
           !openingMovementBounds.contains(point) {
            return false
        }

        if let wallsNode = childNode(withName: "Walls") {
            let localPoint = convert(point, to: wallsNode)
            let path = WallBoundary.makePath()
            guard path.contains(localPoint) else {
                return false
            }
        }
        
        for name in blockingObjectNames {
            guard !collectedObjectNames.contains(name) else {
                continue
            }

            guard let objectNode = childNode(withName: name) else {
                continue
            }
            
            let padding = extraCollisionPadding[name] ?? 0
            let hitFrame = objectNode.frame.insetBy(dx: -padding, dy: -padding)
            
            if hitFrame.contains(point) {
                return false
            }
        }
        
        return true
    }
    
    private func clampedCameraPosition(
        for target: CGPoint
    ) -> CGPoint {
        
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2
        
        let minX = min(
            halfWidth,
            worldSize.width - halfWidth
        )
        
        let maxX = max(
            halfWidth,
            worldSize.width - halfWidth
        )
        
        let minY = min(
            halfHeight,
            worldSize.height - halfHeight
        )
        
        let maxY = max(
            halfHeight,
            worldSize.height - halfHeight
        )
        
        let clampedX = min(
            max(target.x, minX),
            maxX
        )
        
        let clampedY = min(
            max(target.y, minY),
            maxY
        )
        
        return CGPoint(
            x: clampedX,
            y: clampedY
        )
    }
}

private final class RoomHandoffRevealView: UIView {
    private let opaqueLayer = CAShapeLayer()
    private let transitionBandLayer = CAShapeLayer()

    private let targetHoleRadius: CGFloat = 120
    private let targetBandWidth: CGFloat = 75
    private var revealCenter = CGPoint.zero
    private var hasScheduledReveal = false
    private var hasStartedReveal = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false

        opaqueLayer.fillColor = UIColor(
            red: 218 / 255,
            green: 215 / 255,
            blue: 206 / 255,
            alpha: 1
        ).cgColor
        opaqueLayer.fillRule = .evenOdd

        transitionBandLayer.fillColor = UIColor(
            red: 218 / 255,
            green: 215 / 255,
            blue: 206 / 255,
            alpha: 0.5
        ).cgColor
        transitionBandLayer.fillRule = .evenOdd

        layer.addSublayer(opaqueLayer)
        layer.addSublayer(transitionBandLayer)
        applyPaths(holeRadius: 0, bandWidth: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        opaqueLayer.frame = bounds
        transitionBandLayer.frame = bounds

        guard !hasStartedReveal else { return }
        applyPaths(holeRadius: 0, bandWidth: 0)
    }

    func configure(center: CGPoint) {
        revealCenter = center
        applyPaths(holeRadius: 0, bandWidth: 0)
    }

    func scheduleReveal(
        after delay: TimeInterval,
        duration: TimeInterval,
        completion: @escaping () -> Void
    ) {
        guard !hasScheduledReveal else { return }
        hasScheduledReveal = true

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.reveal(duration: duration, completion: completion)
        }
    }

    private func reveal(
        duration: TimeInterval,
        completion: @escaping () -> Void
    ) {
        guard !hasStartedReveal else { return }
        hasStartedReveal = true
        layoutIfNeeded()

        let initialOpaquePath = makeOpaquePath(outerRadius: 0)
        let finalOpaquePath = makeOpaquePath(
            outerRadius: targetHoleRadius + targetBandWidth
        )
        let initialBandPath = makeBandPath(innerRadius: 0, outerRadius: 0)
        let finalBandPath = makeBandPath(
            innerRadius: targetHoleRadius,
            outerRadius: targetHoleRadius + targetBandWidth
        )

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        opaqueLayer.path = finalOpaquePath.cgPath
        transitionBandLayer.path = finalBandPath.cgPath
        CATransaction.commit()

        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)

        let timing = CAMediaTimingFunction(name: .easeInEaseOut)
        addPathAnimation(
            to: opaqueLayer,
            from: initialOpaquePath.cgPath,
            to: finalOpaquePath.cgPath,
            duration: duration,
            timing: timing
        )
        addPathAnimation(
            to: transitionBandLayer,
            from: initialBandPath.cgPath,
            to: finalBandPath.cgPath,
            duration: duration,
            timing: timing
        )
        CATransaction.commit()
    }

    private func applyPaths(holeRadius: CGFloat, bandWidth: CGFloat) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        opaqueLayer.path = makeOpaquePath(
            outerRadius: holeRadius + bandWidth
        ).cgPath
        transitionBandLayer.path = makeBandPath(
            innerRadius: holeRadius,
            outerRadius: holeRadius + bandWidth
        ).cgPath
        CATransaction.commit()
    }

    private func makeOpaquePath(outerRadius: CGFloat) -> UIBezierPath {
        let path = UIBezierPath(rect: bounds)
        path.append(UIBezierPath(ovalIn: circleRect(radius: outerRadius)))
        path.usesEvenOddFillRule = true
        return path
    }

    private func makeBandPath(
        innerRadius: CGFloat,
        outerRadius: CGFloat
    ) -> UIBezierPath {
        let path = UIBezierPath(ovalIn: circleRect(radius: outerRadius))
        path.append(UIBezierPath(ovalIn: circleRect(radius: innerRadius)))
        path.usesEvenOddFillRule = true
        return path
    }

    private func circleRect(radius: CGFloat) -> CGRect {
        CGRect(
            x: revealCenter.x - radius,
            y: revealCenter.y - radius,
            width: radius * 2,
            height: radius * 2
        )
    }

    private func addPathAnimation(
        to layer: CAShapeLayer,
        from initialPath: CGPath,
        to finalPath: CGPath,
        duration: TimeInterval,
        timing: CAMediaTimingFunction
    ) {
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = initialPath
        animation.toValue = finalPath
        animation.duration = duration
        animation.timingFunction = timing
        layer.add(animation, forKey: "roomReveal")
    }
}

#Preview {
    let scene = Room1Scene(
        config: .room1,
        input: InputBridge(),
        dialogHandler: { _, _ in },
        itemCollectedHandler: { _ in true },
        itemUseUnlockedHandler: {},
        activeItemProvider: { nil },
        hasDiscoveredChalkVinegarReactionProvider: { false },
        guidanceHandler: { _, _ in }
    )
    
    scene.scaleMode = .aspectFit
    
    return SpriteView(scene: scene)
        .frame(
            width: 402,
            height: 874
        )
}
