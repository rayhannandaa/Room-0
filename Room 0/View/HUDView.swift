//
//  HUDView.swift
//  Room 0
//
//  Created by Rayhan Nanda on 06/09/26.
//

import SwiftUI

struct HUDView: View {
    @StateObject var viewModel: HUDViewModel
    private let buttons: [HUDButtonConfig] = .room1HUD
    private let artboardSize = CGSize(width: 402, height: 875)

    var body: some View {
        GeometryReader { geo in
            let scaleX = geo.size.width / artboardSize.width
            let scaleY = geo.size.height / artboardSize.height

            ZStack {
                ForEach(buttons, id: \.name) { button in
                    let isDirectional = viewModel.isDirectionalButton(button.name)

                    PressableButton(
                        assetName: button.assetName,
                        size: CGSize(width: button.size.width * scaleX, height: button.size.height * scaleY),
                        respondsToHold: isDirectional,
                        releaseAction: {
                            viewModel.handleRelease(for: button.name)
                        }
                    ) {
                        if isDirectional {
                            viewModel.handlePress(for: button.name)
                        } else {
                            viewModel.handleTap(for: button.name)
                        }
                    }
                    .position(x: button.position.x * scaleX, y: button.position.y * scaleY)
                }
            }
        }
    }
}

#Preview {
    HUDView(viewModel: HUDViewModel(input: InputBridge()))
}
