//
//  BubbleDialogView.swift
//  Room 0
//
//  Created by Rayhan Nanda on 07/09/26.
//

import SwiftUI

struct BubbleDialogView: View {
    @ObservedObject var viewModel: BubbleDialogViewModel
    
    private let slideAnimationDuration: Double = 0.3
    
    private let textFontSize: CGFloat = 18
    private let textWidthFraction: CGFloat = 0.85
    private let textHeightFraction: CGFloat = 0.7
    
    var body: some View {
        GeometryReader { geo in
            let frameSize = BubbleDialogLayout.frameSize(for: geo.size)
            let restingCenter = BubbleDialogLayout.restingCenter(for: geo.size)
            
            if viewModel.isVisible {
                ZStack {
                    Image("BubbleDialog")
                        .resizable()
                        .frame(width: frameSize.width, height: frameSize.height)
                    
                    Text(viewModel.displayedText)
                        .font(ShineTypewriterFont.font(size: textFontSize))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(5)
                        .frame(
                            width: frameSize.width * textWidthFraction,
                            height: frameSize.height * textHeightFraction
                        )
                }
                .position(x: restingCenter.x, y: restingCenter.y)
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .bottom),
                        removal: .move(edge: .bottom)
                    )
                )
                .onTapGesture {
                    viewModel.handleTap()
                }
            }
        }
        .animation(.easeOut(duration: slideAnimationDuration), value: viewModel.isVisible)
    }
}

private struct BubbleDialogPreviewHarness: View {
    @StateObject private var viewModel = BubbleDialogViewModel()
    
    private let sampleSequence = BubbleDialogSequence(lines: [
        BubbleDialogLine(speakerName: "???", text: "Where... am I?"),
        BubbleDialogLine(speakerName: "???", text: "This doesn't look like my room."),
        BubbleDialogLine(speakerName: "???", text: "I need to find a way out of here.")
    ])
    
    var body: some View {
        ZStack {
            Color(hex: "DAD7CE")
                .ignoresSafeArea()
            
            BubbleDialogView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.present(sampleSequence)
        }
    }
}

#Preview {
    BubbleDialogPreviewHarness()
        .frame(width: 402, height: 874)
}
