//
//  MainMenuView.swift
//  Room 0
//

import SwiftUI
import SpriteKit

struct MainMenuView: View {
    @StateObject private var viewModel: MainMenuViewModel
    @State private var scene: MainMenuScene
    private let gameView: GameView
    private let handoffCoordinator: GameHandoffCoordinator

    private let artboardSize = CGSize(width: 402, height: 874)
    private let menuButtonSize = CGSize(width: 300, height: 50)
    private let buttonVerticalGap: CGFloat = 10

    init() {
        let viewModel = MainMenuViewModel()
        let menuScene = MainMenuScene(
            size: CGSize(width: 402, height: 874)
        )
        _viewModel = StateObject(wrappedValue: viewModel)
        _scene = State(wrappedValue: menuScene)

        let handoffCoordinator = GameHandoffCoordinator()
        self.handoffCoordinator = handoffCoordinator

        gameView = GameView(
            usesMenuHandoff: true,
            handoffCoordinator: handoffCoordinator,
            handoffRevealStartDelay: viewModel.model.transitionTiming.roomLoadSettleDuration,
            handoffRevealDuration: viewModel.model.transitionTiming.roomRevealDuration,
            menuHandoffAlignment: { [weak menuScene] characterAnchor, sleepAnimationAnchor in
                menuScene?.setRoomHandoffTargets(
                    characterWindowPoint: characterAnchor,
                    sleepAnimationWindowPoint: sleepAnimationAnchor
                )
            },
            menuHandoffCompletion: { [weak viewModel] in
                viewModel?.completeRoomHandoff()
            }
        )
    }

    var body: some View {
        GeometryReader { geometry in
            let scaleX = geometry.size.width / artboardSize.width
            let scaleY = geometry.size.height / artboardSize.height
            let uniformScale = min(scaleX, scaleY)
            let scaledButtonSize = CGSize(
                width: menuButtonSize.width * uniformScale,
                height: menuButtonSize.height * uniformScale
            )
            ZStack {
                Color(hex: "DAD7CE")

                gameView
                    .opacity(viewModel.showsGame ? 1 : 0)
                    .allowsHitTesting(viewModel.presentationPhase == .game)

                if !viewModel.showsGame {
                    Image("MenuScreen")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .opacity(viewModel.showsMenuBackground ? 1 : 0)
                        .animation(
                            .easeInOut(duration: viewModel.model.transitionTiming.backgroundFadeDuration),
                            value: viewModel.showsMenuBackground
                        )
                }

                VStack(spacing: buttonVerticalGap * uniformScale) {
                    ForEach(viewModel.options) { option in
                        MainMenuButton(
                            title: option.title,
                            size: scaledButtonSize,
                            fontSize: 20 * uniformScale,
                            pressOffset: 5 * uniformScale,
                            action: {
                                viewModel.handleTap(for: option.action)
                            }
                        )
                    }
                }
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height * 0.52
                )
                .opacity(viewModel.showsMenuButtons ? 1 : 0)
                .scaleEffect(viewModel.showsMenuButtons ? 1 : 0.9)
                .animation(
                    .easeOut(duration: viewModel.model.transitionTiming.menuDismissDuration),
                    value: viewModel.showsMenuButtons
                )
                .allowsHitTesting(viewModel.acceptsMenuInput)

                if viewModel.showsMenuCharacter {
                    SpriteView(
                        scene: scene,
                        options: [.allowsTransparency]
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .allowsHitTesting(false)
                }
            }
            .onChange(of: viewModel.movesSleepingCharacter) { _, shouldMove in
                guard shouldMove else { return }
                scene.moveSleepingCharacterToRoom(
                    duration: viewModel.model.transitionTiming.characterMoveDuration
                )
            }
            .onChange(of: viewModel.showsGame) { _, shouldShow in
                guard shouldShow else { return }
                handoffCoordinator.begin()
            }
        }
        .ignoresSafeArea()
    }
}

private struct MainMenuButton: View {
    let title: String
    let size: CGSize
    let fontSize: CGFloat
    let pressOffset: CGFloat
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        ZStack {
            Image("MenuButton")
                .resizable()

            Text(title)
                .font(ShineTypewriterFont.font(size: fontSize))
                .foregroundColor(.black)
        }
        .frame(width: size.width, height: size.height)
        .contentShape(Rectangle())
        .offset(y: isPressed ? pressOffset : 0)
        .animation(.easeOut(duration: 0.08), value: isPressed)
        .onTapGesture {
            isPressed = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                isPressed = false
                action()
            }
        }
    }
}

#Preview {
    MainMenuView()
        .frame(width: 402, height: 874)
}
