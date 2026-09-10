//
//  MainMenuViewModel.swift
//  Room 0
//

import Combine
import Foundation

@MainActor
final class MainMenuViewModel: ObservableObject {
    @Published private(set) var presentationPhase: MainMenuModel.PresentationPhase = .menu

    let model: MainMenuModel
    private var transitionTask: Task<Void, Never>?

    var options: [MainMenuModel.Option] {
        model.options
    }

    var showsGame: Bool {
        switch presentationPhase {
        case .roomCovered, .game:
            return true
        case .menu, .dismissingMenu, .movingCharacter:
            return false
        }
    }

    var showsMenuButtons: Bool {
        presentationPhase == .menu
    }

    var showsMenuBackground: Bool {
        presentationPhase == .menu || presentationPhase == .dismissingMenu
    }

    var showsMenuCharacter: Bool {
        switch presentationPhase {
        case .menu, .dismissingMenu, .movingCharacter:
            return true
        case .game:
            return false
        case .roomCovered:
            return true
        }
    }

    var movesSleepingCharacter: Bool {
        switch presentationPhase {
        case .movingCharacter, .roomCovered, .game:
            return true
        case .menu, .dismissingMenu:
            return false
        }
    }

    var acceptsMenuInput: Bool {
        presentationPhase == .menu
    }

    init(model: MainMenuModel? = nil) {
        self.model = model ?? .initial
    }

    func handleTap(for action: MainMenuModel.Action) {
        switch action {
        case .play:
            beginGameTransition()
        case .continueGame:
            break
        }
    }

    private func beginGameTransition() {
        guard presentationPhase == .menu else { return }

        let timing = model.transitionTiming
        presentationPhase = .dismissingMenu

        transitionTask = Task { [weak self] in
            guard let self else { return }

            await pause(for: timing.menuDismissDuration)
            guard !Task.isCancelled else { return }
            presentationPhase = .movingCharacter

            await pause(for: timing.characterMoveDuration)
            guard !Task.isCancelled else { return }
            presentationPhase = .roomCovered
            transitionTask = nil
        }
    }

    func completeRoomHandoff() {
        guard presentationPhase == .roomCovered else { return }
        presentationPhase = .game
    }

    private func pause(for duration: TimeInterval) async {
        try? await Task.sleep(
            nanoseconds: UInt64(duration * 1_000_000_000)
        )
    }
}
