//
//  Room1ViewModel.swift
//  Room 0
//

enum Room1ExaminationOutcome {
    case none
    case showPickupGuidance
    case unlockLampUse
}

final class Room1ViewModel {
    private(set) var sequenceState: Room1SequenceState = .sleeping
    private(set) var collectedObjects: Set<Room1ObjectID> = []
    private(set) var examinedObjects: Set<Room1ObjectID> = []
    private(set) var isDoorCleared = false

    private var materialsDialoguePending = false

    var shouldStartOpeningDialogue: Bool {
        sequenceState == .sleeping
    }

    var shouldStartInventoryGuidance: Bool {
        sequenceState == .matchboxCollected
    }

    var allowsMovement: Bool {
        switch sequenceState {
        case .searchingForMatchbox, .searchingForLamp, .lampDiscovered, .lampLit:
            true
        default:
            false
        }
    }

    var allowsFullRoomExploration: Bool {
        sequenceState == .lampLit
    }

    func beginSleepingDialogue() {
        sequenceState = .sleepingDialogue
    }

    func beginWakingDialogue() {
        sequenceState = .wakingDialogue
    }

    func beginSearchingForMatchbox() {
        sequenceState = .searchingForMatchbox
    }

    func beginInventoryGuidance() {
        sequenceState = .inventoryGuidance
    }

    func beginPostMatchboxDialogue() {
        sequenceState = .postMatchboxDialogue
    }

    func beginSearchingForLamp() {
        sequenceState = .searchingForLamp
    }

    func lightLamp() {
        sequenceState = .lampLit
    }

    func clearDoor() {
        isDoorCleared = true
    }

    func recordCollection(of object: Room1ObjectID) {
        collectedObjects.insert(object)

        if object == .matchbox {
            sequenceState = .matchboxCollected
        }

        if object == .chalk || object == .vinegarBottle {
            materialsDialoguePending = collectedObjects.contains(.chalk)
                && collectedObjects.contains(.vinegarBottle)
        }
    }

    func consumeMaterialsDialogueRequest() -> Bool {
        guard materialsDialoguePending else { return false }
        materialsDialoguePending = false
        return true
    }

    func recordExamination(of object: Room1ObjectID) -> Room1ExaminationOutcome {
        examinedObjects.insert(object)

        switch object {
        case .matchbox where sequenceState == .searchingForMatchbox:
            return .showPickupGuidance
        case .lamp where sequenceState == .searchingForLamp:
            sequenceState = .lampDiscovered
            return .unlockLampUse
        default:
            return .none
        }
    }

    func isMarkerUnlocked(for object: Room1ObjectID) -> Bool {
        switch object {
        case .matchbox:
            sequenceState == .searchingForMatchbox
        case .lamp:
            sequenceState == .searchingForLamp || sequenceState == .lampDiscovered
        default:
            true
        }
    }

    func canLightLamp(activeItemName: String?) -> Bool {
        sequenceState == .lampDiscovered && activeItemName == "Matchbox"
    }

    func canDissolveDoor(
        reactionDiscovered: Bool,
        activeItemName: String?
    ) -> Bool {
        !isDoorCleared
            && reactionDiscovered
            && activeItemName == "Vinegar"
    }

    func examinationDialogue(
        for object: Room1ObjectID,
        fallback: BubbleDialogSequence,
        reactionDiscovered: Bool
    ) -> BubbleDialogSequence {
        guard object == .lockedDoor, reactionDiscovered else {
            return fallback
        }

        return Room1DialogueCatalog.lockedDoorAfterReaction(
            previouslyExamined: examinedObjects.contains(.lockedDoor)
        )
    }

    func collectedMaterialsDialogue() -> BubbleDialogSequence {
        Room1DialogueCatalog.collectedMaterials(
            journalExamined: examinedObjects.contains(.journal)
        )
    }
}
