//
//  RoomTitleViewModel.swift
//  Room 0
//

import Foundation
import Combine

@MainActor
final class RoomTitleViewModel: ObservableObject {

    @Published private(set) var isVisible = false
    @Published private(set) var displayedText = ""

    private var presentationTask: Task<Void, Never>?
    private var hasPresented = false

    private let typingCharacterInterval: TimeInterval = 0.12
    private let completedTitleHoldDuration: TimeInterval = 1.0
    let fadeDuration: TimeInterval = 0.35

    func present(_ title: String, completion: @escaping () -> Void) {
        guard !hasPresented else { return }
        hasPresented = true

        presentationTask?.cancel()
        displayedText = ""
        isVisible = true

        presentationTask = Task { [weak self] in
            guard let self else { return }

            for character in title {
                if Task.isCancelled { return }

                try? await Task.sleep(
                    nanoseconds: UInt64(typingCharacterInterval * 1_000_000_000)
                )

                if Task.isCancelled { return }
                displayedText.append(character)
            }

            try? await Task.sleep(
                nanoseconds: UInt64(completedTitleHoldDuration * 1_000_000_000)
            )
            if Task.isCancelled { return }

            isVisible = false

            try? await Task.sleep(
                nanoseconds: UInt64(fadeDuration * 1_000_000_000)
            )
            if Task.isCancelled { return }

            completion()
            presentationTask = nil
        }
    }
}
