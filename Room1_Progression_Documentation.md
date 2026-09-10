# Room 0 — Room One Progression

## Overview

Room One is the opening level of Room 0. A young man wakes inside an unfamiliar room that has been converted into a makeshift laboratory. The room begins in darkness, and the player gradually learns how to move, inspect objects, collect items, use the inventory, combine materials, and apply an item to the environment.

The main objective is to illuminate the room, investigate its contents, discover how vinegar reacts with calcium carbonate, and use that knowledge to clear the locked exit.

## Core Gameplay Loop

1. Explore the room.
2. Tap markers to examine objects and read dialogue.
3. Use the Action button to collect, use, or operate nearby objects.
4. Manage collected items through the inventory.
5. Combine Chalk and Vinegar to conduct an experiment.
6. Apply Vinegar to the Locked Door.
7. Clear the doorway and complete Room One.

## Interaction Rules

The two interaction methods have separate responsibilities:

- **Marker tap:** Examines an object and presents its dialogue.
- **Action button:** Collects an item, applies a prepared item, or operates a supported object.

Pressing Action near an object with no available contextual action does nothing.

## Opening Cutscene

### Room Title

When the stage opens:

1. The character is already asleep.
2. The HUD is hidden.
3. `Room 1` appears near the top of the screen with a typewriter effect.
4. The title remains visible for one second.
5. The title fades out.
6. The first sleeping dialogue bubble appears automatically.

The room title uses the same 18-point Shine Typewriter font as the bubble dialogue.

### Sleeping Sequence

The character uses the sleeping animation while the `Zzz` animation plays. The player taps the bubble to progress through three lines:

1. `...`
2. `...`
3. `...`

After the third line, the character wakes and returns to the downward idle animation.

### Waking Dialogue

1. “Where... am I?”
2. “What is this place?”
3. “It's too dark. I can barely see anything.”
4. “I need to find something that can make a light.”

The HUD becomes visible after this dialogue ends.

## Initial Dark Exploration

Before the Lamp is lit:

- Only the Shelf, Lamp, Matchbox, walls, and floor are available in the opening area.
- Player movement is restricted to the opening exploration bounds.
- The character begins near the lower edge of the area.
- The Matchbox sits between the character and the Lamp.
- A small breathing vision halo limits how much of the room is visible.
- The Matchbox has collision until it is collected.

## Matchbox Progression

### Matchbox Examination

The Matchbox marker becomes visible when the player is close enough. Tapping it presents:

1. “A matchbox... and the matches are still dry.”
2. “This could help me see what's hidden in here.”

### Action Button Tutorial

After the examination dialogue, a guidance overlay highlights the Action button:

> “Tap the action button to pick up nearby objects.”

Tapping the highlighted Action button performs the real collection action.

### Collection Result

- The room asset uses `Matchbox`.
- The inventory slot uses `MatchboxInven`.
- The Matchbox sprite, marker, physics body, and manual movement collision are removed.
- Inventory opens automatically with the Matchbox selected.
- The Use button is still hidden at this stage.

### Inventory Button Tutorial

After the player dismisses the automatic inventory screen, a guidance overlay highlights the Inventory button:

> “Use the inventory button to check what you've collected.”

This tutorial only identifies the button and does not reopen Inventory.

### Post-Collection Dialogue

1. “Matches... but they won't help on their own.”
2. “I need to find something nearby that I can light.”

The Lamp marker becomes available after this dialogue.

## Lamp Progression

### Lamp Examination

1. “An old oil lamp. It looks like there's still some fuel inside.”
2. “These matches should be enough to light it.”

Examining the Lamp unlocks item use and starts the Use tutorial.

### Item Use Tutorial

1. Inventory button:
   > “Open your inventory to choose an item.”
2. Use button:
   > “Tap Use to prepare the selected item.”
3. Action button:
   > “Use the action button to apply it to a nearby object.”

The tutorial opens Inventory, selects the Matchbox, prepares it, and guides the player to apply it to the Lamp.

### Lighting the Lamp

When the prepared Matchbox is applied:

- The Lamp itself does not receive an artificial glow.
- The small vision halo expands to the original large Room One halo.
- The large halo remains visible and continues its frame-by-frame breathing animation.
- Remaining room objects are revealed.
- The opening movement restriction is removed.
- The player gains access to the full room.

### Room-Revealed Dialogue

1. “The lamp is lit. I can finally see.”
2. “This room... something about it feels wrong.”
3. “I need to explore this place and find a way out.”

## Full-Room Exploration

After the Lamp is lit, markers become available for the Locked Door, Journal, Chalk, and Vinegar Bottle. Markers appear only when the player is close enough to the reachable edge of an object, rather than its center.

This edge-based calculation prevents tables and other collision areas from making markers difficult to reach.

## Locked Door

### Initial Dialogue

1. “I think this is the way out.”
2. “But it's locked... and this strange white buildup is jammed around the mechanism.”
3. “Was this done deliberately?”
4. “There has to be a way to dissolve or break it apart.”

The room records whether the player has examined the door so later dialogue can avoid unnecessary repetition.

## Journal

### Dialogue

1. “A handwritten journal... someone was conducting experiments here.”
2. “One entry says weak acids react with calcium carbonate and produce bubbles.”
3. “This might explain some of the materials in this room.”

The room records whether the Journal was examined. This changes the first line of the dialogue shown after both chemistry materials are collected.

## Chalk

### Examination Dialogue

1. “A piece of ordinary chalk.”
2. “It crumbles easily. There must be a reason it was left here.”

### Collection

- Collected with the Action button.
- Uses `Chalk` in the room.
- Uses `ChalkInven` in Inventory.
- Its sprite, marker, physics body, and manual collision are removed after collection.

## Vinegar Bottle

### Examination Dialogue

1. “That sharp smell... this is vinegar.”
2. “A weak acid. Maybe I can test it on something in this room.”

### Collection

- Collected with the Action button.
- Uses `VinegarBottle` in the room.
- Uses `VinegarInven` in Inventory.
- Its sprite, marker, physics body, and manual collision are removed after collection.
- Collision belonging to the table beneath the bottle remains active.

## Materials-Collected Dialogue

This dialogue plays once after the second chemistry material is collected and the automatically opened Inventory is dismissed.

### If the Journal Was Not Examined

1. “Chalk and vinegar...”
2. “These can't have been left here together by accident.”
3. “I should mix a small amount and see how they react.”

### If the Journal Was Examined

1. “The chalk and vinegar—these must be the materials mentioned in the journal.”
2. “These can't have been left here together by accident.”
3. “I should mix a small amount and see how they react.”

## Inventory Combination System

### Availability

- The Combine button is hidden while the player owns only one chemistry material.
- It remains hidden during the automatic inventory presentations after collection.
- It is permanently unlocked when the first combination tutorial begins.
- After the tutorial, combinable items always show Combine when selected.
- Chalk and Vinegar are currently the registered Room One recipe.
- The recipe works in either ingredient order.

### Combination Layout

The information panel changes into an equation:

`[First Ingredient] + [Second Ingredient] = [?]`

- Combination slots are 45 × 45, matching standard inventory slots.
- Each equation element aligns with the inventory grid columns:
  - First ingredient: column 1
  - External `+`: column 2
  - Second ingredient: column 3
  - `=`: column 4
  - Result: column 5
- The in-slot `+` and `?` match the external equation symbols at size 20.
- The player taps the in-slot `+` before choosing the second ingredient.
- Selected ingredient slots use the darker selected fill with a short transition.
- Cancel exits combination mode.
- The final Combine button is enabled only for a valid recipe.

### Combination Tutorial

After the materials-collected dialogue finishes:

1. Inventory button:
   > “Open your inventory to experiment with the materials.”
2. First material slot:
   > “Select either the chalk or vinegar.”
3. Initial Combine button:
   > “Tap Combine to place it in the first slot.”
4. Empty ingredient slot:
   > “Tap the + slot to add another ingredient.”
5. Remaining material slot:
   > “Select the other material from your inventory.”
6. Final Combine button:
   > “Tap Combine to test the two materials together.”

Every highlighted tutorial tap performs the real underlying action.

### Chalk–Vinegar Reaction

Combining Chalk and Vinegar does not create a new inventory item. The player is considered to have tested only a small sample, so both items remain available.

The completed experiment is recorded as puzzle knowledge.

Reaction dialogue:

1. “It's bubbling...”
2. “The vinegar is reacting with the chalk.”
3. “The acid must be breaking down the calcium carbonate.”

## Post-Reaction Door Dialogue

### If the Door Was Previously Examined

1. “That white buildup around the mechanism...”
2. “If it contains calcium carbonate, the vinegar should break it down.”
3. “I should try using the vinegar on the door.”

### If This Is the First Door Examination

1. “The door is locked, and this white buildup is jamming the mechanism.”
2. “It looks like the chalk I tested.”
3. “The vinegar should break it down.”

## Clearing the Door

The door action becomes available when all of the following are true:

- The Chalk–Vinegar reaction has been completed.
- Vinegar has been selected and prepared with Use.
- The player is close enough to the Locked Door.
- The player presses Action.

### Current Temporary Presentation

1. Player movement is disabled.
2. The Locked Door marker is removed.
3. The door physics body is removed.
4. The door fades out over 0.4 seconds.
5. The door node is removed.
6. The existing wall polygon continues controlling the doorway and wall collision.
7. The player can enter the cleared doorway without walking through the visible wall border.

No custom dissolve artwork, particles, shaking, glow, or shader is currently used.

### Door-Cleared Dialogue

1. “It worked. The vinegar dissolved the buildup.”
2. “The mechanism is free, and the way is open.”
3. “Whatever is beyond this door... maybe it will tell me why I'm here.”

Movement returns when the dialogue ends.

## Shared UI Presentation

- Bubble dialogue uses the Shine Typewriter font at size 18.
- Guidance text uses the same font at size 18.
- Room title uses the same font at size 18.
- Bubble dialogue, guidance messages, and inventory information use five-point multiline spacing.
- Guidance cards use `DAD7CE` fill, `2A292B` stroke, two-point stroke width, and approximately 15-point corner radius.
- Guidance overlays use static circular cutouts without radar or pulse animation.
- HUD controls remain hidden while bubble dialogue is visible.

## Architecture

Room One currently follows a mixed SpriteKit and SwiftUI MVVM structure:

- `Room1Scene` manages room objects, movement, proximity, collisions, markers, environmental actions, and narrative progression.
- `Room1SequenceState` represents the major opening-sequence states.
- `InputBridge` connects SwiftUI controls to SpriteKit gameplay.
- `BubbleDialogViewModel` manages dialogue sequences and typewriter presentation.
- `GuidanceViewModel` manages tutorial steps and performs their highlighted actions.
- `InventoryViewModel` manages item slots, active items, combination state, recipe completion, and inventory visibility.
- `RoomTitleViewModel` manages the opening title typewriter sequence.
- `InventoryCombinationRecipe` defines valid ingredient combinations and reaction dialogue.

## Room One Completion State

The complete first-pass Room One loop is implemented:

- Opening presentation
- Waking sequence
- Initial limited exploration
- Matchbox discovery and collection
- Inventory and Action tutorials
- Lamp discovery and lighting
- Full-room reveal
- Object examination
- Chalk and Vinegar collection
- Combination tutorial
- Chemistry reaction discovery
- Contextual Locked Door dialogue
- Vinegar application
- Door removal
- Corrected doorway collision

## Future Improvements

The following improvements are intentionally deferred:

- Purpose-built dissolve or unlocking animation for the door
- Bubble or fizz particles around the calcium-carbonate buildup
- Audio and haptic feedback for chemistry reactions
- A dedicated visual result for non-item-producing combinations
- Room One completion trigger at the end of the doorway
- Transition from Room One to Room Two
- Persistence and save-game support
