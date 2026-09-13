//
//  InventoryView.swift
//  Room 0
//
//  Created by Rayhan Nanda on 08/09/26.
//

import SwiftUI

struct InventoryView: View {
    @ObservedObject var viewModel: InventoryViewModel
    
    private let titleFontSize: CGFloat = 12
    private let infoNameFontSize: CGFloat = 14
    private let infoDescriptionFontSize: CGFloat = 12
    
    private let slotCornerRadius: CGFloat = 8
    private let slotFillDefault = Color(hex: "B6B2A9")
    private let slotFillSelected = Color(hex: "7E7B74")
    private let slotStroke = Color(hex: "2A292B")
    private let slotStrokeWidth: CGFloat = 2
    
    private let useButtonSize = CGSize(width: 50, height: 20)
    private let useButtonCornerRadius: CGFloat = 5
    private let useButtonFontSize: CGFloat = 10
    private let useButtonFill = Color(hex: "B6B2A9")
    private let useButtonStroke = Color(hex: "2A292B")
    private let useButtonStrokeWidth: CGFloat = 2
    private let useButtonTextEnabled = Color.black
    private let useButtonTextDisabled = Color(hex: "DAD7CE")
    private let combineButtonSize = CGSize(width: 65, height: 20)
    private let combinationSlotSize: CGFloat = 45
    
    var body: some View {
        GeometryReader { geo in
            let scaleX = geo.size.width / InventoryLayout.artboardSize.width
            let scaleY = geo.size.height / InventoryLayout.artboardSize.height
            let uniformScale = min(scaleX, scaleY)
            
            let cardFrame = InventoryLayout.scaledFrame(for: InventoryLayout.cardRect, in: geo.size)
            let titleFrame = InventoryLayout.scaledFrame(for: InventoryLayout.titleRect, in: geo.size)
            let infoFrame = InventoryLayout.scaledFrame(for: InventoryLayout.infoRect, in: geo.size)
            let infoHorizontalInset = InventoryLayout.infoTextHorizontalInset * uniformScale
            let infoVerticalInset = InventoryLayout.infoTextVerticalInset * uniformScale
            let textToButtonPadding = InventoryLayout.textToUseButtonPadding * uniformScale
            let buttonTrailingPadding = InventoryLayout.useButtonTrailingPadding * uniformScale
            let buttonBottomPadding = InventoryLayout.useButtonBottomPadding * uniformScale
            
            let buttonSize = CGSize(width: useButtonSize.width * uniformScale, height: useButtonSize.height * uniformScale)
            let scaledCombineButtonSize = CGSize(
                width: combineButtonSize.width * uniformScale,
                height: combineButtonSize.height * uniformScale
            )
            let buttonCenter = CGPoint(
                x: infoFrame.maxX - buttonTrailingPadding - buttonSize.width / 2,
                y: infoFrame.maxY - buttonBottomPadding - buttonSize.height / 2
            )
            let combineButtonCenter = CGPoint(
                x: buttonCenter.x - buttonSize.width / 2 - (8 * uniformScale) - scaledCombineButtonSize.width / 2,
                y: buttonCenter.y
            )
            let textFrame = CGRect(
                x: infoFrame.minX + infoHorizontalInset,
                y: infoFrame.minY + infoVerticalInset,
                width: max(0, infoFrame.width - (infoHorizontalInset * 2)),
                height: max(
                    0,
                    buttonCenter.y - buttonSize.height / 2 - textToButtonPadding
                        - (infoFrame.minY + infoVerticalInset)
                )
            )
            
            ZStack {
                Color.black.opacity(viewModel.isVisible ? 0.4 : 0)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.20), value: viewModel.isVisible)
                    .onTapGesture {
                        viewModel.dismiss()
                    }
                
                ZStack {
                    Image("Inventory")
                        .resizable()
                        .frame(width: cardFrame.width, height: cardFrame.height)
                        .position(x: cardFrame.midX, y: cardFrame.midY)
                    
                    Text("INVENTORY")
                        .font(ShineTypewriterFont.font(size: titleFontSize * uniformScale))
                        .foregroundColor(.black)
                        .frame(width: titleFrame.width, height: titleFrame.height, alignment: .leading)
                        .position(x: titleFrame.midX, y: titleFrame.midY)
                    
                    ForEach(Array(InventoryLayout.slotRects.enumerated()), id: \.offset) { index, rect in
                        let slotFrame = InventoryLayout.scaledFrame(for: rect, in: geo.size)
                        let isSelected = viewModel.selectedIndex == index
                            || viewModel.combinationSecondIndex == index
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: slotCornerRadius)
                                .fill(isSelected ? slotFillSelected : slotFillDefault)
                                .overlay(
                                    RoundedRectangle(cornerRadius: slotCornerRadius)
                                        .stroke(slotStroke, lineWidth: slotStrokeWidth)
                                )
                            
                            if let item = viewModel.slots[index], let iconName = item.iconAssetName {
                                Image(iconName)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(6)
                            }
                        }
                        .frame(width: slotFrame.width, height: slotFrame.height)
                        .position(x: slotFrame.midX, y: slotFrame.midY)
                        .animation(.easeInOut(duration: 0.15), value: isSelected)
                        .onTapGesture {
                            viewModel.selectSlot(at: index)
                        }
                    }
                    
                    Image("InventoryInfo")
                        .resizable()
                        .frame(width: infoFrame.width, height: infoFrame.height)
                        .position(x: infoFrame.midX, y: infoFrame.midY)
                    
                    if viewModel.isCombining {
                        let scaledCombinationSlotSize = combinationSlotSize * uniformScale
                        let slotCenterY = infoFrame.minY + (32 * uniformScale)
                        let equationColumnCenters = InventoryLayout.slotRects.prefix(5).map { rect in
                            InventoryLayout.scaledFrame(for: rect, in: geo.size).midX
                        }
                        let firstSlotCenterX = equationColumnCenters[0]
                        let plusCenterX = equationColumnCenters[1]
                        let secondSlotCenterX = equationColumnCenters[2]
                        let equalsCenterX = equationColumnCenters[3]
                        let resultSlotCenterX = equationColumnCenters[4]
                        let combineActionCenter = CGPoint(
                            x: infoFrame.maxX - (12 * uniformScale) - scaledCombineButtonSize.width / 2,
                            y: infoFrame.maxY - (12 * uniformScale) - scaledCombineButtonSize.height / 2
                        )
                        let cancelActionCenter = CGPoint(
                            x: combineActionCenter.x - scaledCombineButtonSize.width / 2 - (8 * uniformScale) - buttonSize.width / 2,
                            y: combineActionCenter.y
                        )

                        combinationSlot(
                            item: viewModel.combinationFirstItem,
                            placeholder: "?",
                            isHighlighted: false,
                            uniformScale: uniformScale
                        )
                        .frame(width: scaledCombinationSlotSize, height: scaledCombinationSlotSize)
                        .position(x: firstSlotCenterX, y: slotCenterY)

                        Text("+")
                            .font(ShineTypewriterFont.font(size: 20 * uniformScale))
                            .foregroundColor(Color(hex: "2A292B"))
                            .position(x: plusCenterX, y: slotCenterY)

                        combinationSlot(
                            item: viewModel.combinationSecondItem,
                            placeholder: "+",
                            isHighlighted: viewModel.isChoosingSecondIngredient,
                            uniformScale: uniformScale
                        )
                        .frame(width: scaledCombinationSlotSize, height: scaledCombinationSlotSize)
                        .position(x: secondSlotCenterX, y: slotCenterY)
                        .onTapGesture {
                            viewModel.beginChoosingSecondIngredient()
                        }

                        Text("=")
                            .font(ShineTypewriterFont.font(size: 20 * uniformScale))
                            .foregroundColor(Color(hex: "2A292B"))
                            .position(x: equalsCenterX, y: slotCenterY)

                        combinationSlot(
                            item: nil,
                            placeholder: "?",
                            isHighlighted: false,
                            uniformScale: uniformScale
                        )
                        .frame(width: scaledCombinationSlotSize, height: scaledCombinationSlotSize)
                        .position(x: resultSlotCenterX, y: slotCenterY)

                        inventoryActionButton(
                            title: "Cancel",
                            isEnabled: true,
                            uniformScale: uniformScale
                        )
                        .frame(width: buttonSize.width, height: buttonSize.height)
                        .position(x: cancelActionCenter.x, y: cancelActionCenter.y)
                        .onTapGesture {
                            viewModel.cancelCombination()
                        }

                        inventoryActionButton(
                            title: "Combine",
                            isEnabled: viewModel.matchingCombinationRecipe != nil,
                            uniformScale: uniformScale
                        )
                        .frame(width: scaledCombineButtonSize.width, height: scaledCombineButtonSize.height)
                        .position(x: combineActionCenter.x, y: combineActionCenter.y)
                        .onTapGesture {
                            guard viewModel.matchingCombinationRecipe != nil else { return }
                            viewModel.completeCombination()
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 10 * uniformScale) {
                            if let item = viewModel.selectedItem {
                                Text(item.name)
                                    .font(ShineTypewriterFont.font(size: infoNameFontSize * uniformScale))
                                    .foregroundColor(.black)
                                    .lineSpacing(5 * uniformScale)
                                
                                Text(item.description)
                                    .font(ShineTypewriterFont.font(size: infoDescriptionFontSize * uniformScale))
                                    .foregroundColor(.black)
                                    .lineSpacing(5 * uniformScale)
                            }
                        }
                        .frame(
                            width: textFrame.width,
                            height: textFrame.height,
                            alignment: .topLeading
                        )
                        .position(x: textFrame.midX, y: textFrame.midY)

                        if viewModel.canSelectedItemCombine {
                            inventoryActionButton(
                                title: "Combine",
                                isEnabled: true,
                                uniformScale: uniformScale
                            )
                            .frame(width: scaledCombineButtonSize.width, height: scaledCombineButtonSize.height)
                            .position(x: combineButtonCenter.x, y: combineButtonCenter.y)
                            .onTapGesture {
                                viewModel.startCombination()
                            }
                        }
                        
                        if viewModel.selectedItem != nil, viewModel.isUseAvailable {
                            let isActive = viewModel.isSelectedItemActive

                            inventoryActionButton(
                                title: "Use",
                                isEnabled: !isActive,
                                uniformScale: uniformScale
                            )
                            .frame(width: buttonSize.width, height: buttonSize.height)
                            .position(x: buttonCenter.x, y: buttonCenter.y)
                            .onTapGesture {
                                guard !isActive else { return }
                                viewModel.useSelectedItem()
                            }
                        }
                    }
                }
                .scaleEffect(viewModel.isVisible ? 1 : 0.8)
                .opacity(viewModel.isVisible ? 1 : 0)
                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: viewModel.isVisible)
            }
            .allowsHitTesting(viewModel.isVisible)
        }
    }

    private func combinationSlot(
        item: InventoryItem?,
        placeholder: String,
        isHighlighted: Bool,
        uniformScale: CGFloat
    ) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: slotCornerRadius)
                .fill(isHighlighted ? slotFillSelected : slotFillDefault)
                .overlay(
                    RoundedRectangle(cornerRadius: slotCornerRadius)
                        .stroke(
                            slotStroke,
                            lineWidth: isHighlighted ? 3 : slotStrokeWidth
                        )
                )

            if let iconName = item?.iconAssetName {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .padding(5)
            } else {
                Text(placeholder)
                    .font(ShineTypewriterFont.font(size: 20 * uniformScale))
                    .foregroundColor(Color(hex: "2A292B"))
            }
        }
    }

    private func inventoryActionButton(
        title: String,
        isEnabled: Bool,
        uniformScale: CGFloat
    ) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: useButtonCornerRadius)
                .fill(useButtonFill)
                .overlay(
                    Group {
                        if isEnabled {
                            RoundedRectangle(cornerRadius: useButtonCornerRadius)
                                .stroke(useButtonStroke, lineWidth: useButtonStrokeWidth)
                        }
                    }
                )

            Text(title)
                .font(ShineTypewriterFont.font(size: useButtonFontSize * uniformScale))
                .foregroundColor(isEnabled ? useButtonTextEnabled : useButtonTextDisabled)
        }
    }
}

private struct InventoryPreviewHarness: View {
    @StateObject private var input = InputBridge()
    @StateObject private var viewModel: InventoryViewModel
    
    init() {
        let bridge = InputBridge()
        _input = StateObject(wrappedValue: bridge)
        _viewModel = StateObject(wrappedValue: InventoryViewModel(input: bridge))
    }
    
    var body: some View {
        ZStack {
            Color(hex: "DAD7CE").ignoresSafeArea()
            InventoryView(viewModel: viewModel)
        }
        .onAppear {
            input.isInventoryOpen = true
            viewModel.addItem(ItemCatalog.vinegarBottle())
            viewModel.addItem(ItemCatalog.chalk())
        }
    }
}

#Preview {
    InventoryPreviewHarness()
        .frame(width: 402, height: 874)
}
