//
//  Room1ObjectID.swift
//  Room 0
//

enum Room1ObjectID: String, CaseIterable, Hashable {
    case floor = "Floor"
    case walls = "Walls"
    case shelf = "Shelf"
    case machine = "Machine"
    case table = "Table"
    case chair = "Chair"
    case tableTwo = "TableTwo"
    case vent = "Vent"
    case lockedDoor = "LockDoor"
    case chalk = "Chalk"
    case doubleBottle = "DoubleBottle"
    case lamp = "Lamp"
    case journal = "Journal"
    case bottleOne = "Bottle_1"
    case bottleTwo = "Bottle_2"
    case vinegarBottle = "VinegarBottle"
    case matchbox = "Matchbox"
}

extension RoomObjectConfig {
    var room1ObjectID: Room1ObjectID? {
        Room1ObjectID(rawValue: name)
    }
}
