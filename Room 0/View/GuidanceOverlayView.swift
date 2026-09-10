//
//  GuidanceOverlayView.swift
//  Room 0
//

import SwiftUI

struct GuidanceOverlayView: View {
    @ObservedObject var viewModel: GuidanceViewModel

    var body: some View {
        ZStack {
            if let step = viewModel.currentStep {
                GuidanceStepOverlay(step: step) {
                    withAnimation(.easeOut(duration: 0.18)) {
                        viewModel.handleHighlightedButtonTap()
                    }
                }
                .id(step.id)
                .transition(.asymmetric(insertion: .identity, removal: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.18), value: viewModel.currentStep?.id)
    }
}

private struct GuidanceStepOverlay: View {
    let step: GuidanceStep
    let action: () -> Void

    @State private var hasAppeared = false

    private let artboardSize = CGSize(width: 402, height: 875)

    private let cutoutPadding: CGFloat = 24
    private let cardWidth: CGFloat = 350
    private let cardHeight: CGFloat = 76
    private let cardCornerRadius: CGFloat = 15
    private let cardStrokeWidth: CGFloat = 2
    private let messageHorizontalPadding: CGFloat = 18
    private let messageFontSize: CGFloat = 18

    var body: some View {
        GeometryReader { geo in
            let scaleX = geo.size.width / artboardSize.width
            let scaleY = geo.size.height / artboardSize.height
            let uniformScale = min(scaleX, scaleY)

            let buttonCenter = CGPoint(
                x: step.targetButtonCenter.x * scaleX,
                y: step.targetButtonCenter.y * scaleY
            )
            let cutoutDiameter = max(
                step.targetButtonSize.width * scaleX,
                step.targetButtonSize.height * scaleY
            ) + (cutoutPadding * 2 * uniformScale)
            let cutoutRect = CGRect(
                x: buttonCenter.x - cutoutDiameter / 2,
                y: buttonCenter.y - cutoutDiameter / 2,
                width: cutoutDiameter,
                height: cutoutDiameter
            )

            ZStack {
                Color.black.opacity(0.55)
                    .mask {
                        Canvas { context, size in
                            var path = Path(CGRect(origin: .zero, size: size))
                            path.addEllipse(in: cutoutRect)
                            context.fill(
                                path,
                                with: .color(.white),
                                style: FillStyle(eoFill: true)
                            )
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { }
                    .opacity(hasAppeared ? 1 : 0)

                Text(step.message)
                    .font(ShineTypewriterFont.font(size: messageFontSize * uniformScale))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5 * uniformScale)
                    .padding(.horizontal, messageHorizontalPadding * uniformScale)
                    .frame(
                        width: cardWidth * scaleX,
                        height: cardHeight * scaleY
                    )
                    .background {
                        RoundedRectangle(cornerRadius: cardCornerRadius * uniformScale)
                            .fill(Color(hex: "DAD7CE"))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cardCornerRadius * uniformScale)
                            .stroke(
                                Color(hex: "2A292B"),
                                lineWidth: cardStrokeWidth * uniformScale
                            )
                    }
                    .position(
                        x: geo.size.width / 2,
                        y: geo.size.height / 2
                    )
                    .scaleEffect(hasAppeared ? 1 : 0.96)
                    .offset(y: hasAppeared ? 0 : -10 * uniformScale)
                    .opacity(hasAppeared ? 1 : 0)

                Color.clear
                    .contentShape(Circle())
                    .frame(width: cutoutDiameter, height: cutoutDiameter)
                    .position(buttonCenter)
                    .allowsHitTesting(hasAppeared)
                    .onTapGesture(perform: action)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeOut(duration: 0.25).delay(step.appearanceDelay)) {
                hasAppeared = true
            }
        }
    }
}

private struct GuidancePreviewHarness: View {
    @StateObject private var input: InputBridge
    @StateObject private var viewModel: GuidanceViewModel

    init() {
        let input = InputBridge()
        let inventoryViewModel = InventoryViewModel(input: input)
        _input = StateObject(wrappedValue: input)
        _viewModel = StateObject(
            wrappedValue: GuidanceViewModel(
                input: input,
                inventoryViewModel: inventoryViewModel
            )
        )
    }

    var body: some View {
        ZStack {
            Color(hex: "DAD7CE").ignoresSafeArea()
            HUDView(viewModel: HUDViewModel(input: input))
            GuidanceOverlayView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.present(.pickupObject)
        }
    }
}

#Preview {
    GuidancePreviewHarness()
        .frame(width: 402, height: 875)
}
