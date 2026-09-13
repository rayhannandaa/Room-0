//
//  PressableButton.swift
//  Room 0
//
//  Created by Rayhan Nanda on 06/09/26.
//

import SwiftUI
import Foundation

struct PressableButton: View {
    let assetName: String
    let size: CGSize
    var respondsToHold = false
    var releaseAction: () -> Void = { }
    let action: () -> Void

    @State private var isPressed = false
    @State private var isTouchActive = false
    @State private var pressBeganAt: Date?
    @State private var pressGeneration = 0

    private let minimumPressDuration: TimeInterval = 0.08

    var body: some View {
        Image(assetName)
            .resizable()
            .frame(width: size.width, height: size.height)
            .offset(y: isPressed ? 5 : 0)
            .animation(.easeOut(duration: 0.08), value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !isTouchActive else { return }
                        isTouchActive = true
                        isPressed = true
                        pressBeganAt = Date()
                        pressGeneration += 1

                        if respondsToHold {
                            action()
                        }
                    }
                    .onEnded { _ in
                        isTouchActive = false

                        if respondsToHold {
                            releaseAction()
                        } else {
                            action()
                        }

                        finishVisualPress()
                    }
            )
            .onDisappear {
                if isTouchActive, respondsToHold {
                    releaseAction()
                }
                isTouchActive = false
            }
    }

    private func finishVisualPress() {
        let elapsed = pressBeganAt.map { Date().timeIntervalSince($0) } ?? minimumPressDuration
        let remainingDuration = max(0, minimumPressDuration - elapsed)
        let completedGeneration = pressGeneration

        guard remainingDuration > 0 else {
            isPressed = false
            pressBeganAt = nil
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + remainingDuration) {
            guard pressGeneration == completedGeneration else { return }
            isPressed = false
            pressBeganAt = nil
        }
    }
}
