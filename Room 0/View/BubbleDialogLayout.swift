//
//  BubbleDialogLayout.swift
//  Room 0
//
//  Created by Rayhan Nanda on 07/09/26.
//

import CoreGraphics

enum BubbleDialogLayout {

    static let artboardSize = CGSize(width: 402, height: 874)
    static let designRect = CGRect(x: 26, y: 659.7, width: 350, height: 184.3)
    
    static func frameSize(for containerSize: CGSize) -> CGSize {
        let scaleX = containerSize.width / artboardSize.width
        let scaleY = containerSize.height / artboardSize.height
        return CGSize(
            width: designRect.width * scaleX,
            height: designRect.height * scaleY
        )
    }
    
    static func restingCenter(for containerSize: CGSize) -> CGPoint {
        let scaleX = containerSize.width / artboardSize.width
        let scaleY = containerSize.height / artboardSize.height
        let centerX = (designRect.minX + designRect.width / 2) * scaleX
        let centerY = (designRect.minY + designRect.height / 2) * scaleY
        return CGPoint(x: centerX, y: centerY)
    }
}
