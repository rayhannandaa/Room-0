//
//  InventoryLayout.swift
//  Room 0
//
//  Created by Rayhan Nanda on 08/09/26.
//

import CoreGraphics

enum InventoryLayout {
    static let artboardSize = CGSize(width: 402, height: 874)
    
    static let cardRect = CGRect(x: 26, y: 301.8, width: 350, height: 160.5)
    static let titleRect = CGRect(x: 49.6, y: 312, width: 72, height: 8.9)
    
    static let infoRect = CGRect(x: 26, y: 472.2, width: 350, height: 100)
    static let infoTextHorizontalInset: CGFloat = 16
    static let infoTextVerticalInset: CGFloat = 14
    static let textToUseButtonPadding: CGFloat = 14
    static let useButtonTrailingPadding: CGFloat = 12
    static let useButtonBottomPadding: CGFloat = 12
    
    static let slotSize = CGSize(width: 45, height: 45)
    static let firstSlotOrigin = CGPoint(x: 41, y: 342.2)
    static let columns = 6
    static let rows = 2
    static let horizontalGap: CGFloat = 10
    static let verticalGap: CGFloat = 15
    
    static var slotRects: [CGRect] {
        var rects: [CGRect] = []
        for row in 0..<rows {
            for col in 0..<columns {
                let x = firstSlotOrigin.x + CGFloat(col) * (slotSize.width + horizontalGap)
                let y = firstSlotOrigin.y + CGFloat(row) * (slotSize.height + verticalGap)
                rects.append(CGRect(x: x, y: y, width: slotSize.width, height: slotSize.height))
            }
        }
        return rects
    }
    
    static func scaledFrame(for rect: CGRect, in containerSize: CGSize) -> CGRect {
        let scaleX = containerSize.width / artboardSize.width
        let scaleY = containerSize.height / artboardSize.height
        return CGRect(
            x: rect.minX * scaleX,
            y: rect.minY * scaleY,
            width: rect.width * scaleX,
            height: rect.height * scaleY
        )
    }
}
