//
//  InventoryItem.swift
//  Room 0
//
//  Created by Rayhan Nanda on 08/09/26.
//

import Foundation

struct InventoryItem: Identifiable {
    let id: String
    let name: String
    let description: String
    let iconAssetName: String?
    
    init(id: String = UUID().uuidString, name: String, description: String, iconAssetName: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.iconAssetName = iconAssetName
    }
}
