//
//  InventoryCombinationRecipe.swift
//  Room 0
//

import Foundation

struct InventoryCombinationRecipe {
    let ingredientNames: Set<String>
    let reactionDialogue: BubbleDialogSequence

    func matches(_ firstItem: InventoryItem, _ secondItem: InventoryItem) -> Bool {
        ingredientNames == Set([firstItem.name, secondItem.name])
    }
}

extension InventoryCombinationRecipe {
    static let chalkAndVinegar = InventoryCombinationRecipe(
        ingredientNames: ["Chalk", "Vinegar"],
        reactionDialogue: BubbleDialogSequence(lines: [
            BubbleDialogLine(speakerName: "Young Man", text: "It's bubbling..."),
            BubbleDialogLine(speakerName: "Young Man", text: "The vinegar is reacting with the chalk."),
            BubbleDialogLine(speakerName: "Young Man", text: "The acid must be breaking down the calcium carbonate.")
        ])
    )

    static let roomOneRecipes: [InventoryCombinationRecipe] = [
        .chalkAndVinegar
    ]
}
