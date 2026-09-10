//
//  GameView.swift
//  Room 0
//
//  Created by Rayhan Nanda on 06/09/26.
//

import SwiftUI
import SpriteKit
import Foundation

@MainActor
final class GameHandoffCoordinator {
    private var startAction: (() -> Void)?
    private var isStartRequested = false
    private var hasStarted = false

    func register(startAction: @escaping () -> Void) {
        self.startAction = startAction
        startIfReady()
    }

    func begin() {
        isStartRequested = true
        startIfReady()
    }

    private func startIfReady() {
        guard isStartRequested,
              !hasStarted,
              let startAction
        else {
            return
        }

        hasStarted = true
        startAction()
    }
}

struct GameView: View {
    static let sceneVisibleHeight: CGFloat = {
        let hudTopEdge = 737.35 - (57.5 / 2)
        return hudTopEdge - 50
    }()

    @StateObject private var input = InputBridge()
    @StateObject private var inventoryViewModel: InventoryViewModel
    @StateObject private var bubbleDialogViewModel: BubbleDialogViewModel
    @StateObject private var guidanceViewModel: GuidanceViewModel
    @StateObject private var roomTitleViewModel: RoomTitleViewModel
    @State private var scene: Room1Scene
    @State private var hasStartedOpening = false

    private let openingStartDelay: TimeInterval

    private let artboardSize = CGSize(width: 402, height: 874)
    private let usesMenuHandoff: Bool
    private let handoffCoordinator: GameHandoffCoordinator?
    private let handoffRevealStartDelay: TimeInterval
    private let handoffRevealDuration: TimeInterval
    private let menuHandoffAlignment: ((CGPoint, CGPoint) -> Void)?
    private let menuHandoffCompletion: (() -> Void)?

    init(
        openingStartDelay: TimeInterval = 0,
        usesMenuHandoff: Bool = false,
        handoffCoordinator: GameHandoffCoordinator? = nil,
        handoffRevealStartDelay: TimeInterval = 0,
        handoffRevealDuration: TimeInterval = 0.65,
        menuHandoffAlignment: ((CGPoint, CGPoint) -> Void)? = nil,
        menuHandoffCompletion: (() -> Void)? = nil
    ) {
        self.openingStartDelay = openingStartDelay
        self.usesMenuHandoff = usesMenuHandoff
        self.handoffCoordinator = handoffCoordinator
        self.handoffRevealStartDelay = handoffRevealStartDelay
        self.handoffRevealDuration = handoffRevealDuration
        self.menuHandoffAlignment = menuHandoffAlignment
        self.menuHandoffCompletion = menuHandoffCompletion

        let bridge = InputBridge()
        _input = StateObject(wrappedValue: bridge)

        let dialogViewModel = BubbleDialogViewModel()
        _bubbleDialogViewModel = StateObject(wrappedValue: dialogViewModel)

        let inventoryViewModel = InventoryViewModel(
            input: bridge,
            combinationCompletedHandler: { recipe in
                Task { @MainActor in
                    dialogViewModel.present(recipe.reactionDialogue)
                }
            }
        )
        _inventoryViewModel = StateObject(wrappedValue: inventoryViewModel)

        let guidanceViewModel = GuidanceViewModel(
            input: bridge,
            inventoryViewModel: inventoryViewModel
        )
        _guidanceViewModel = StateObject(wrappedValue: guidanceViewModel)
        
        let titleViewModel = RoomTitleViewModel()
        _roomTitleViewModel = StateObject(wrappedValue: titleViewModel)
        
        let scene = Room1Scene(
            config: .room1,
            input: bridge,
            dialogHandler: { sequence, completion in
                Task { @MainActor in
                    dialogViewModel.present(sequence, completion: completion)
                }
            },
            itemCollectedHandler: { item in
                inventoryViewModel.collectAndPresent(item)
            },
            itemUseUnlockedHandler: {
                inventoryViewModel.unlockItemUse()
            },
            activeItemProvider: {
                inventoryViewModel.activeItem
            },
            hasDiscoveredChalkVinegarReactionProvider: {
                inventoryViewModel.hasDiscoveredChalkVinegarReaction
            },
            guidanceHandler: { step, completion in
                Task { @MainActor in
                    guidanceViewModel.present(step, completion: completion)
                }
            }
        )
        scene.scaleMode = .aspectFill
        scene.prepareForPresentation(
            usesMenuHandoff: usesMenuHandoff,
            menuHandoffAlignment: menuHandoffAlignment
        )
        _scene = State(wrappedValue: scene)
    }

    var body: some View {
        GeometryReader { geo in
            let scaleY = geo.size.height / artboardSize.height
            let frameHeight = Self.sceneVisibleHeight * scaleY
            let isHUDVisible = input.controlsEnabled && !bubbleDialogViewModel.isVisible

            ZStack(alignment: .top) {
                Color(hex: "DAD7CE")
                    .ignoresSafeArea()

                SpriteView(scene: scene, options: [.allowsTransparency])
                    .frame(width: geo.size.width, height: frameHeight)
                    .clipped()

                HUDView(viewModel: HUDViewModel(input: input))
                    .opacity(isHUDVisible ? 1 : 0)
                    .allowsHitTesting(isHUDVisible)
                    .animation(.easeInOut(duration: 0.2), value: isHUDVisible)
                
                InventoryView(viewModel: inventoryViewModel)
                
                BubbleDialogView(viewModel: bubbleDialogViewModel)

                RoomTitleView(viewModel: roomTitleViewModel)

                GuidanceOverlayView(viewModel: guidanceViewModel)
            }
            .onAppear {
                if usesMenuHandoff, let handoffCoordinator {
                    handoffCoordinator.register {
                        beginMenuHandoff()
                    }
                } else {
                    startOpeningIfNeeded()
                }
            }
        }
        .ignoresSafeArea()
    }

    private func startOpeningIfNeeded() {
        guard !hasStartedOpening else { return }
        hasStartedOpening = true

        Task { @MainActor in
            if openingStartDelay > 0 {
                try? await Task.sleep(
                    nanoseconds: UInt64(openingStartDelay * 1_000_000_000)
                )
            }
            presentRoomTitle()
        }
    }

    private func beginMenuHandoff() {
        scene.beginMenuHandoffReveal(
            after: handoffRevealStartDelay,
            duration: handoffRevealDuration
        ) {
            scene.resumeOpeningAnimationAfterMenuHandoff()
            menuHandoffCompletion?()
            presentRoomTitle()
        }
    }

    private func presentRoomTitle() {
        roomTitleViewModel.present("Room 1") {
            input.beginOpeningSequence()
        }
    }
}

#Preview {
    GameView()
}
