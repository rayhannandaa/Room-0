# Room 0

Room 0 is a narrative-driven 2D chemistry escape-room game for iOS. A young man wakes up inside an unfamiliar room that has been converted into a makeshift laboratory. To escape, the player must explore the environment, understand the materials around them, conduct simple experiments, and uncover why they were brought there.

## Gameplay

The main gameplay loop is built around four actions:

- **Explore** the room and discover objects, materials, and clues.
- **Interact** with marked objects to examine them or trigger an action.
- **Collect and manage** useful materials through the inventory.
- **Experiment and combine** compatible items to discover chemical reactions and solve obstacles.

Each room presents a new problem to overcome and another piece of the story to uncover.

## Current Progress

Room 1 currently includes:

- A main menu with Play and Continue buttons.
- A cinematic transition from the menu into the opening scene.
- A semi-automatic opening sequence with a sleeping character and dialogue.
- Limited early exploration using a small vision halo.
- Guided tutorials for the Action button, inventory, item use, and item combination.
- Collectible matches, chalk, and vinegar.
- Object-specific dialogue for the lamp, journal, materials, and locked door.
- An inventory with item descriptions, Use actions, and combination slots.
- A chalk-and-vinegar reaction with conditional dialogue.
- A locked-door puzzle that can be cleared using the discovered reaction.
- Expanded exploration after the lamp is lit.

## Room 1 Puzzle

The first room introduces the player to the game's chemistry mechanics through a calcium carbonate obstruction around a locked door. The player can examine a journal, collect chalk and vinegar, test how the materials react, and apply that discovery to clear the way forward.

## Controls

- Use the directional buttons to move around the room.
- Tap a visible marker to examine an object.
- Use the Action button to collect, use, or operate a nearby object.
- Open the inventory to inspect, select, use, or combine collected items.
- Tap dialogue bubbles to continue conversations.

## Technology

- Swift
- SwiftUI
- SpriteKit
- MVVM architecture for the menu, HUD, inventory, dialogue, and guidance systems
- Xcode asset catalogs for characters, environments, objects, and interface artwork

## Project Structure

```text
Room 0/
├── Models/
├── ViewModel/
├── View/
├── Scenes/
├── Nodes/
├── Rooms/
├── StateMachines/
├── Input/
├── Utilities/
└── Assets.xcassets/
```

## Running the Project

1. Clone the repository:

   ```bash
   git clone https://github.com/rayhannandaa/Room-0.git
   ```

2. Open `Room 0.xcodeproj` in Xcode.
3. Select a compatible iPhone simulator or connected device.
4. Build and run the project.

The project currently targets iOS 26.5 and uses Swift 5 language mode.

## Development Status

Room 0 is actively being developed. Room 1 has a complete first-pass gameplay flow, while additional rooms, story progression, visual polish, and save/continue behavior are planned for future development.

## Asset Ownership

All original artwork and game assets belong to the project creator. They may not be copied, redistributed, or used in another project without permission.
