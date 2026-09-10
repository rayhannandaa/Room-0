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
                dialog: BubbleDialogSequence(lines: [
                    BubbleDialogLine(text: "I think this is the way out."),
                    BubbleDialogLine(text: "But it's locked... and this strange white buildup is jammed around the mechanism."),
                    BubbleDialogLine(text: "Was this done deliberately?"),
                    BubbleDialogLine(text: "There has to be a way to dissolve or break it apart.")
                ])
            ),
            RoomObjectConfig(
                name: "Chalk",
                assetName: "Chalk",
                size: CGSize(width: 114.4, height: 72.8),
                position: CGPoint(x: 67.2, y: 595),
                zPosition: 2,
                isInteractable: true,
                dialog: BubbleDialogSequence(lines: [
                    BubbleDialogLine(text: "A piece of ordinary chalk."),
                    BubbleDialogLine(text: "It crumbles easily. There must be a reason it was left here.")
                ]),
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
                dialog: BubbleDialogSequence(lines: [
                    BubbleDialogLine(text: "An old oil lamp. It looks like there's still some fuel inside."),
                    BubbleDialogLine(text: "These matches should be enough to light it.")
                ])
            ),
            RoomObjectConfig(
                name: "Journal",
                assetName: "Journal",
                size: CGSize(width: 61, height: 67),
                position: CGPoint(x: 540, y: 555),
                zPosition: 2,
                isInteractable: true,
                dialog: BubbleDialogSequence(lines: [
                    BubbleDialogLine(text: "A handwritten journal... someone was conducting experiments here."),
                    BubbleDialogLine(text: "One entry says weak acids react with calcium carbonate and produce bubbles."),
                    BubbleDialogLine(text: "This might explain some of the materials in this room.")
                ])
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
                dialog: BubbleDialogSequence(lines: [
                    BubbleDialogLine(text: "That sharp smell... this is vinegar."),
                    BubbleDialogLine(text: "A weak acid. Maybe I can test it on something in this room.")
                ]),
                collectibleItem: ItemCatalog.vinegarBottle()
            ),
            RoomObjectConfig(
                name: "Matchbox",
                assetName: "Matchbox",
                size: CGSize(width: 50, height: 61),
                position: CGPoint(x: 337.5, y: 460),
                zPosition: 2.4,
                isInteractable: true,
                dialog: BubbleDialogSequence(lines: [
                    BubbleDialogLine(text: "A matchbox... and the matches are still dry."),
                    BubbleDialogLine(text: "This could help me see what's hidden in here.")
                ]),
                collectibleItem: ItemCatalog.matchbox()
            )
        ]
    )
}
