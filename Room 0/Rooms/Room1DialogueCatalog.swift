//
//  Room1DialogueCatalog.swift
//  Room 0
//

enum Room1DialogueCatalog {
    static let sleeping = BubbleDialogSequence(lines: [
        BubbleDialogLine(text: "..."),
        BubbleDialogLine(text: "..."),
        BubbleDialogLine(text: "...")
    ])

    static let waking = BubbleDialogSequence(lines: [
        BubbleDialogLine(speakerName: "Young Man", text: "Where... am I?"),
        BubbleDialogLine(speakerName: "Young Man", text: "What is this place?"),
        BubbleDialogLine(speakerName: "Young Man", text: "It's too dark. I can barely see anything."),
        BubbleDialogLine(speakerName: "Young Man", text: "I need to find something that can make a light.")
    ])

    static let postMatchbox = BubbleDialogSequence(lines: [
        BubbleDialogLine(speakerName: "Young Man", text: "Matches... but they won't help on their own."),
        BubbleDialogLine(speakerName: "Young Man", text: "I need to find something nearby that I can light.")
    ])

    static let roomRevealed = BubbleDialogSequence(lines: [
        BubbleDialogLine(speakerName: "Young Man", text: "The lamp is lit. I can finally see."),
        BubbleDialogLine(speakerName: "Young Man", text: "This room... something about it feels wrong."),
        BubbleDialogLine(speakerName: "Young Man", text: "I need to explore this place and find a way out.")
    ])

    static let doorCleared = BubbleDialogSequence(lines: [
        BubbleDialogLine(speakerName: "Young Man", text: "It worked. The vinegar dissolved the buildup."),
        BubbleDialogLine(speakerName: "Young Man", text: "The mechanism is free, and the way is open."),
        BubbleDialogLine(speakerName: "Young Man", text: "Whatever is beyond this door... maybe it will tell me why I'm here.")
    ])

    static let lockedDoorInitial = BubbleDialogSequence(lines: [
        BubbleDialogLine(text: "I think this is the way out."),
        BubbleDialogLine(text: "But it's locked... and this strange white buildup is jammed around the mechanism."),
        BubbleDialogLine(text: "Was this done deliberately?"),
        BubbleDialogLine(text: "There has to be a way to dissolve or break it apart.")
    ])

    static let chalk = BubbleDialogSequence(lines: [
        BubbleDialogLine(text: "A piece of ordinary chalk."),
        BubbleDialogLine(text: "It crumbles easily. There must be a reason it was left here.")
    ])

    static let lamp = BubbleDialogSequence(lines: [
        BubbleDialogLine(text: "An old oil lamp. It looks like there's still some fuel inside."),
        BubbleDialogLine(text: "These matches should be enough to light it.")
    ])

    static let journal = BubbleDialogSequence(lines: [
        BubbleDialogLine(text: "A handwritten journal... someone was conducting experiments here."),
        BubbleDialogLine(text: "One entry says weak acids react with calcium carbonate and produce bubbles."),
        BubbleDialogLine(text: "This might explain some of the materials in this room.")
    ])

    static let vinegar = BubbleDialogSequence(lines: [
        BubbleDialogLine(text: "That sharp smell... this is vinegar."),
        BubbleDialogLine(text: "A weak acid. Maybe I can test it on something in this room.")
    ])

    static let matchbox = BubbleDialogSequence(lines: [
        BubbleDialogLine(text: "A matchbox... and the matches are still dry."),
        BubbleDialogLine(text: "This could help me see what's hidden in here.")
    ])

    static func collectedMaterials(journalExamined: Bool) -> BubbleDialogSequence {
        let openingLine = journalExamined
            ? "The chalk and vinegar—these must be the materials mentioned in the journal."
            : "Chalk and vinegar..."

        return BubbleDialogSequence(lines: [
            BubbleDialogLine(speakerName: "Young Man", text: openingLine),
            BubbleDialogLine(speakerName: "Young Man", text: "These can't have been left here together by accident."),
            BubbleDialogLine(speakerName: "Young Man", text: "I should mix a small amount and see how they react.")
        ])
    }

    static func lockedDoorAfterReaction(previouslyExamined: Bool) -> BubbleDialogSequence {
        if previouslyExamined {
            return BubbleDialogSequence(lines: [
                BubbleDialogLine(speakerName: "Young Man", text: "That white buildup around the mechanism..."),
                BubbleDialogLine(speakerName: "Young Man", text: "If it contains calcium carbonate, the vinegar should break it down."),
                BubbleDialogLine(speakerName: "Young Man", text: "I should try using the vinegar on the door.")
            ])
        }

        return BubbleDialogSequence(lines: [
            BubbleDialogLine(speakerName: "Young Man", text: "The door is locked, and this white buildup is jamming the mechanism."),
            BubbleDialogLine(speakerName: "Young Man", text: "It looks like the chalk I tested."),
            BubbleDialogLine(speakerName: "Young Man", text: "The vinegar should break it down.")
        ])
    }
}
