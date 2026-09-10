//
//  ItemCatalog.swift
//  Room 0
//
//  Created by Rayhan Nanda on 08/09/26.
//

import Foundation

enum ItemCatalog {
    static func matchbox() -> InventoryItem {
        InventoryItem(
            name: "Matchbox",
            description: "A small box containing a few dry matches.",
            iconAssetName: "MatchboxInven"
        )
    }

    static func vinegarBottle() -> InventoryItem {
        InventoryItem(
            name: "Vinegar",
            description: "A weak acid. Might dissolve certain mineral buildups.",
            iconAssetName: "VinegarInven"
        )
    }
    
    static func chalk() -> InventoryItem {
        InventoryItem(
            name: "Chalk",
            description: "Calcium carbonate. Reacts with acidic substances.",
            iconAssetName: "ChalkInven"
        )
    }
}
