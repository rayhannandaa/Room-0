//
//  RoomTitleView.swift
//  Room 0
//

import SwiftUI

struct RoomTitleView: View {
    @ObservedObject var viewModel: RoomTitleViewModel

    var body: some View {
        GeometryReader { geometry in
            if viewModel.isVisible {
                Text(viewModel.displayedText)
                    .font(ShineTypewriterFont.font(size: 24))
                    .foregroundColor(.black)
                    .frame(width: geometry.size.width)
                    .position(
                        x: geometry.size.width / 2,
                        y: 100
                    )
                    .transition(.opacity)
            }
        }
        .allowsHitTesting(false)
        .animation(
            .easeOut(duration: viewModel.fadeDuration),
            value: viewModel.isVisible
        )
    }
}
