//
//  Room1Config.swift
//  Room 0
//
//  Created by Rayhan Nanda on 06/09/26.
//

import CoreGraphics

extension RoomConfig {
    static let room1 = RoomConfig(
        sceneSize: CGSize(width: 750, height: 800),
        objects: [
            RoomObjectConfig(name: "Floor", assetName: "Floor", size: CGSize(width: 750, height: 800), position: CGPoint(x: 375, y: 400), zPosition: 0),
            RoomObjectConfig(name: "Walls", assetName: "Walls", size: CGSize(width: 750, height: 800), position: CGPoint(x: 375, y: 400), zPosition: 1),
            
            RoomObjectConfig(name: "Shelf", assetName: "Shelf", size: CGSize(width: 275, height: 102.5), position: CGPoint(x: 300, y: 718.75), zPosition: 2),
            RoomObjectConfig(name: "Machine", assetName: "Machine", size: CGSize(width: 120.1, height: 293), position: CGPoint(x: 70.05, y: 398.5), zPosition: 2),
            RoomObjectConfig(name: "Table", assetName: "Table", size: CGSize(width: 75, height: 232.6), position: CGPoint(x: 552.5, y: 558.5), zPosition: 2),
            RoomObjectConfig(name: "Chair", assetName: "Chair", size: CGSize(width: 57.5, height: 120), position: CGPoint(x: 476.25, y: 556.2), zPosition: 2),
            RoomObjectConfig(name: "TableTwo", assetName: "TableTwo", size: CGSize(width: 265, height: 124.7), position: CGPoint(x: 150, y: 62.35), zPosition: 2),
            RoomObjectConfig(name: "Vent", assetName: "Vent", size: CGSize(width: 150, height: 89.7), position: CGPoint(x: 532, y: 154.85), zPosition: 2),
            RoomObjectConfig(
                name: "LockDoor",
                assetName: "LockDoor",
                size: CGSize(width: 69, height: 200),
                position: CGPoint(x: 691.5, y: 200),
                zPosition: 2,
                isInteractable: true,
                dialog: Room1DialogueCatalog.lockedDoorInitial
            ),
            RoomObjectConfig(
                name: "Chalk",
                assetName: "Chalk",
                size: CGSize(width: 114.4, height: 72.8),
                position: CGPoint(x: 67.2, y: 595),
                zPosition: 2,
                isInteractable: true,
                dialog: Room1DialogueCatalog.chalk,
                collectibleItem: ItemCatalog.chalk()
            ),
            RoomObjectConfig(name: "DoubleBottle", assetName: "DoubleBottle", size: CGSize(width: 71.5, height: 68.3), position: CGPoint(x: 544.25, y: 379.05), zPosition: 2),
            
            RoomObjectConfig(
                name: "Lamp",
                assetName: "Lamp",
                size: CGSize(width: 40, height: 59.9),
                position: CGPoint(x: 300, y: 762.45),
                zPosition: 2,
                isInteractable: true,
                dialog: Room1DialogueCatalog.lamp
            ),
            RoomObjectConfig(
                name: "Journal",
                assetName: "Journal",
                size: CGSize(width: 61, height: 67),
                position: CGPoint(x: 540, y: 555),
                zPosition: 2,
                isInteractable: true,
                dialog: Room1DialogueCatalog.journal
            ),
            RoomObjectConfig(name: "Bottle_1", assetName: "Bottle", size: CGSize(width: 27, height: 55.1), position: CGPoint(x: 41, y: 116.45), zPosition: 3),
            RoomObjectConfig(name: "Bottle_2", assetName: "Bottle", size: CGSize(width: 27, height: 55.1), position: CGPoint(x: 88, y: 116.45), zPosition: 3),
            RoomObjectConfig(
                name: "VinegarBottle",
                assetName: "VinegarBottle",
                size: CGSize(width: 28.5, height: 53.4),
                position: CGPoint(x: 258.25, y: 115.9),
                zPosition: 3,
                isInteractable: true,
                dialog: Room1DialogueCatalog.vinegar,
                collectibleItem: ItemCatalog.vinegarBottle()
            ),
            RoomObjectConfig(
                name: "Matchbox",
                assetName: "Matchbox",
                size: CGSize(width: 50, height: 61),
                position: CGPoint(x: 337.5, y: 460),
                zPosition: 2.4,
                isInteractable: true,
                dialog: Room1DialogueCatalog.matchbox,
                collectibleItem: ItemCatalog.matchbox()
            )
        ]
    )
}
