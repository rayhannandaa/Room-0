//
//  HUDLayout.swift
//  Room 0
//
//  Created by Rayhan Nanda on 06/09/26.
//

import CoreGraphics

extension Array where Element == HUDButtonConfig {
    static let room1HUD: [HUDButtonConfig] = [
        HUDButtonConfig(name: "Up", assetName: "Up", size: CGSize(width: 50, height: 57.5), position: CGPoint(x: 201, y: 737.35)),
        HUDButtonConfig(name: "Down", assetName: "Down", size: CGSize(width: 50, height: 57.5), position: CGPoint(x: 201, y: 795.05)),
        HUDButtonConfig(name: "Left", assetName: "Left", size: CGSize(width: 50, height: 57.5), position: CGPoint(x: 146, y: 795.05)),
        HUDButtonConfig(name: "Right", assetName: "Right", size: CGSize(width: 50, height: 57.5), position: CGPoint(x: 256, y: 795.05)),
        HUDButtonConfig(name: "InventoryButton", assetName: "InventoryButton", size: CGSize(width: 50, height: 57.5), position: CGPoint(x: 61, y: 795.05)),
        HUDButtonConfig(name: "ActionButton", assetName: "ActionButton", size: CGSize(width: 50, height: 57.5), position: CGPoint(x: 341, y: 795.05))
    ]
}
