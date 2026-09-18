import SpriteKit
import SwiftUI
import UIKit

class Room1Scene: SKScene {
    static let openingCharacterAnchorY: CGFloat = 210
    
    private let config: RoomConfig
    private let dependencies: Room1SceneDependencies
    private var input: InputBridge { dependencies.input }
    private var dialogHandler: (BubbleDialogSequence, (() -> Void)?) -> Void {
        dependencies.presentDialog
    }
    private var itemCollectedHandler: (InventoryItem) -> Bool {
        dependencies.collectItem
    }
    private var itemUseUnlockedHandler: () -> Void {
        dependencies.unlockItemUse
    }
    private var activeItemProvider: () -> InventoryItem? {
        dependencies.activeItem
    }
    private var hasDiscoveredChalkVinegarReactionProvider: () -> Bool {
        dependencies.hasDiscoveredChalkVinegarReaction
    }
    private var guidanceHandler: (GuidanceStep, (() -> Void)?) -> Void {
        dependencies.presentGuidance
    }
    private let character = CharacterNode()
    private let cameraNode = SKCameraNode()
    private let sleepAnimationNode = SleepAnimationNode()
    private let roomViewModel = Room1ViewModel()
    private lazy var worldController = Room1WorldController(
        scene: self,
        config: config
    )
    private lazy var interactionController = Room1InteractionController(
        character: character,
        world: worldController
    )
    private lazy var movementController = Room1MovementController(
        scene: self,
        input: input,
        character: character,
        cameraNode: cameraNode,
        world: worldController,
        worldSize: worldSize
    )

    private let visionOverlay = VisionOverlayNode(holeDiameter: 220)
    private var lastProcessedInteractTrigger = 0
    private var hasPreparedSceneContents = false
    private var usesMenuHandoff = false
    private var menuHandoffAlignment: ((CGPoint, CGPoint) -> Void)?
    private var pendingMenuHandoffReveal: (
        delay: TimeInterval,
        duration: TimeInterval,
        completion: () -> Void
    )?
    
    private let worldSize: CGSize

    init(
        config: RoomConfig,
        dependencies: Room1SceneDependencies
    ) {
        self.config = config
        self.dependencies = dependencies
        
        self.worldSize = Room1Rules.worldSize(for: config.sceneSize)
        
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
        worldController.buildOpeningWorld()
        setupCharacter()
        prepareOpeningSequence()
    }
    
    private func setupCharacter() {
        character.position = CGPoint(
            x: 375 + Room1Rules.sidePadding,
            y: Self.openingCharacterAnchorY + Room1Rules.bottomPadding
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
        
        movementController.synchronizeCameraPosition()
    }
    
    override func update(_ currentTime: TimeInterval) {
        interactionController.updateMarkerVisibility(
            controlsEnabled: input.controlsEnabled,
            inventoryOpen: input.isInventoryOpen,
            isUnlocked: roomViewModel.isMarkerUnlocked
        )

        if roomViewModel.shouldStartOpeningDialogue,
           !input.isOpeningSequencePending {
            startOpeningDialogue()
            return
        }

        if input.interactTrigger != lastProcessedInteractTrigger {
            lastProcessedInteractTrigger = input.interactTrigger
            handleInteraction()
        }

        if roomViewModel.shouldStartInventoryGuidance,
           !input.isInventoryOpen {
            startInventoryGuidance()
            return
        }

        if !input.isInventoryOpen,
           roomViewModel.consumeMaterialsDialogueRequest() {
            presentCollectedMaterialsDialogue()
            return
        }

        movementController.update(
            allowsMovement: roomViewModel.allowsMovement,
            allowsFullRoomExploration: roomViewModel.allowsFullRoomExploration,
            inventoryOpen: input.isInventoryOpen,
            collectedObjects: roomViewModel.collectedObjects
        )
    }
    
    private func handleInteraction() {
        guard input.controlsEnabled, !input.isInventoryOpen else { return }

        guard let objectID = interactionController.nearestRevealedObject(),
              let objectNode = worldController.node(for: objectID),
              let objectConfig = worldController.configuration(for: objectID)
        else {
            return
        }

        if objectID == .lamp,
           roomViewModel.canLightLamp(
               activeItemName: activeItemProvider()?.name
           ) {
            startLampLightingSequence()
            return
        }

        if objectID == .lockedDoor,
           roomViewModel.canDissolveDoor(
               reactionDiscovered: hasDiscoveredChalkVinegarReactionProvider(),
               activeItemName: activeItemProvider()?.name
           ) {
            startDoorDissolvingSequence(doorNode: objectNode)
            return
        }

        if let item = objectConfig.collectibleItem {
            guard itemCollectedHandler(item) else { return }

            roomViewModel.recordCollection(of: objectID)
            worldController.removeObject(objectID)
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
        guard let objectID = interactionController.revealedObject(
            at: location,
            in: self
        ), let marker = worldController.marker(for: objectID) else { return }

        let dialog = roomViewModel.examinationDialogue(
            for: objectID,
            fallback: marker.dialog,
            reactionDiscovered: hasDiscoveredChalkVinegarReactionProvider()
        )

        presentExaminationDialog(dialog) { [weak self] in
            self?.handleCompletedExamination(of: objectID)
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

    private func handleCompletedExamination(of object: Room1ObjectID) {
        switch roomViewModel.recordExamination(of: object) {
        case .showPickupGuidance:
            guidanceHandler(.pickupObject, nil)
        case .unlockLampUse:
            itemUseUnlockedHandler()
            guidanceHandler(.openInventoryForItem, nil)
        case .none:
            break
        }
    }

    private func presentCollectedMaterialsDialogue() {
        input.controlsEnabled = false
        input.pendingDirection = nil

        let sequence = roomViewModel.collectedMaterialsDialogue()

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
        roomViewModel.beginSleepingDialogue()

        dialogHandler(Room1DialogueCatalog.sleeping) { [weak self] in
            self?.startWakingDialogue()
        }
    }

    private func startWakingDialogue() {
        roomViewModel.beginWakingDialogue()
        sleepAnimationNode.stop()
        sleepAnimationNode.removeFromParent()
        character.setIdle(direction: .down)

        dialogHandler(Room1DialogueCatalog.waking) { [weak self] in
            guard let self else { return }
            self.roomViewModel.beginSearchingForMatchbox()
            self.input.controlsEnabled = true
        }
    }

    private func startPostMatchboxDialogue() {
        roomViewModel.beginPostMatchboxDialogue()
        input.controlsEnabled = false

        dialogHandler(Room1DialogueCatalog.postMatchbox) { [weak self] in
            guard let self else { return }
            self.roomViewModel.beginSearchingForLamp()
            self.input.controlsEnabled = true
        }
    }

    private func startInventoryGuidance() {
        roomViewModel.beginInventoryGuidance()
        input.pendingDirection = nil
        guidanceHandler(.inventoryInformation) { [weak self] in
            self?.startPostMatchboxDialogue()
        }
    }

    private func startLampLightingSequence() {
        roomViewModel.lightLamp()
        input.controlsEnabled = false
        input.pendingDirection = nil

        worldController.removeMarker(for: .lamp)
        worldController.revealRemainingWorld(
            excluding: roomViewModel.collectedObjects
        )

        visionOverlay.expandVision(to: 505) { [weak self] in
            self?.presentRoomRevealedDialogue()
        }
    }

    private func presentRoomRevealedDialogue() {
        dialogHandler(Room1DialogueCatalog.roomRevealed) { [weak self] in
            self?.input.controlsEnabled = true
        }
    }

    private func startDoorDissolvingSequence(doorNode: SKNode) {
        input.controlsEnabled = false
        input.pendingDirection = nil

        worldController.removeMarker(for: .lockedDoor)

        doorNode.physicsBody = nil

        let fadeOut = SKAction.fadeOut(withDuration: 0.4)
        fadeOut.timingMode = .easeOut

        doorNode.run(.sequence([
            fadeOut,
            .run { [weak self] in
                guard let self else { return }

                self.worldController.removeObject(.lockedDoor)
                self.roomViewModel.clearDoor()
                self.presentDoorClearedDialogue()
            }
        ]))
    }

    private func presentDoorClearedDialogue() {
        dialogHandler(Room1DialogueCatalog.doorCleared) { [weak self] in
            self?.input.controlsEnabled = true
        }
    }
}

#Preview {
    let scene = Room1Scene(
        config: .room1,
        dependencies: Room1SceneDependencies(
            input: InputBridge(),
            presentDialog: { _, _ in },
            collectItem: { _ in true },
            unlockItemUse: {},
            activeItem: { nil },
            hasDiscoveredChalkVinegarReaction: { false },
            presentGuidance: { _, _ in }
        )
    )
    
    scene.scaleMode = .aspectFit
    
    return SpriteView(scene: scene)
        .frame(
            width: 402,
            height: 874
        )
}
