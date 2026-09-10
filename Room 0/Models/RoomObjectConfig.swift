//
//  RoomObjectConfig.swift
//  Room 0
//
//  Created by Rayhan Nanda on 06/09/26.
//

import Foundation
import CoreGraphics

struct RoomObjectConfig {
    let name: String
    let assetName: String
    let size: CGSize
    let position: CGPoint
    let zPosition: CGFloat
    let isInteractable: Bool
    let dialog: BubbleDialogSequence?
    let collectibleItem: InventoryItem?

    init(
        name: String,
        assetName: String,
        size: CGSize,
        position: CGPoint,
        zPosition: CGFloat,
        isInteractable: Bool = false,
        dialog: BubbleDialogSequence? = nil,
        collectibleItem: InventoryItem? = nil
    ) {
        self.name = name
        self.assetName = assetName
        self.size = size
        self.position = position
        self.zPosition = zPosition
        self.isInteractable = isInteractable
        self.dialog = dialog
        self.collectibleItem = collectibleItem
    }
}
