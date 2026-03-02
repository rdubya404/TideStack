# TideStack

A polished iOS block-stacking game where you race against the rising tide!

## Overview

TideStack is a fast-paced arcade game built with SwiftUI and SpriteKit. Stack blocks as high as you can before the tide catches up. Perfect placements keep your full width, while imperfect placements cut your block down. Build combos for bonus points!

## Features

- **Beautiful Visuals**: Ocean-themed graphics with animated waves, twinkling stars, and colorful blocks
- **Smooth Animations**: 60fps gameplay with particle effects for perfect placements and block chips
- **Sound Effects**: Audio feedback for drops, perfect placements, combos, and game over
- **Intuitive Controls**: Simple tap-to-place gameplay
- **Auto-Drop Timer**: 5-second timer adds pressure to each move
- **Combo System**: Chain perfect placements for bonus points
- **Tide Mechanic**: The tide rises continuously, creating urgency

## Game Mechanics

1. **Tap to Place**: Tap anywhere to drop the moving block
2. **Perfect Placement**: Land within 18 pixels of the edge for a perfect (keep full width)
3. **Imperfect Placement**: Block gets cut to the overlapping width
4. **Auto-Drop**: Block drops automatically after 5 seconds
5. **Tide Rising**: The tide continuously rises - don't let it catch your stack!
6. **Game Over**: When the tide touches your top block or you miss completely

## Technical Details

- **Platform**: iOS 16.0+
- **Frameworks**: SwiftUI, SpriteKit, AVFoundation
- **Language**: Swift 5.0
- **Orientation**: Portrait only

## Project Structure

```
TideStack/
├── TideStack/
│   ├── TideStackApp.swift          # App entry point
│   ├── ContentView.swift           # Main SwiftUI view
│   ├── TideStackGameScene.swift    # Main game scene (SpriteKit)
│   ├── SoundManager.swift          # Audio management
│   ├── Assets.xcassets/            # App icons and assets
│   └── Preview Content/            # SwiftUI previews
└── TideStack.xcodeproj/            # Xcode project
```

## Building

1. Open `TideStack.xcodeproj` in Xcode 15.0 or later
2. Select your target device or simulator
3. Build and run (⌘+R)

## Future Enhancements

- [ ] Custom sound effects (currently using system sounds)
- [ ] Background music
- [ ] High score persistence
- [ ] Leaderboards (Game Center)
- [ ] Haptic feedback
- [ ] Additional visual themes
- [ ] Power-ups

## Credits

Original HTML5 game concept converted to native iOS with SpriteKit.
