# Menu Screen Design

## Current Menu Layout

```
┌────────────────────────────────┐
│                                │
│        Doodle Jump             │  ← Title (48pt)
│          (title)               │
│                                │
│         [spacer 30px]          │
│                                │
│                                │
│         [spacer 30px]          │
│                                │
│          Best: 4250            │  ← High Score (24pt)
│                                │
│         [spacer 40px]          │
│                                │
│       ┌──────────────────┐     │
│       │  Start Game      │     │  ← Button (50px height)
│       └──────────────────┘     │
│                                │
│         [spacer fill]          │
│                                │
└────────────────────────────────┘
```

## Interaction Methods

### Primary (Recommended)
- **Mouse**: Click the "Start Game" button
- **Touch**: Tap the "Start Game" button

### Accessibility Fallback
- **Mouse**: Click anywhere on the menu screen
- **Touch**: Tap anywhere on the menu screen

## Component Hierarchy

```
Main (Node2D)
└── HUD (CanvasLayer)
    └── StartScreen (VBoxContainer)
        ├── TitleLabel (Label) "Doodle Jump"
        ├── Spacer1 (Control) - 30px
        ├── Spacer2 (Control) - 30px
        ├── HighScoreLabel (Label) "Best: 0"
        ├── Spacer3 (Control) - 40px
        └── StartButton (Button) "Start Game"
```

## Visual Specifications

| Component | Property | Value |
|-----------|----------|-------|
| Title | Font Size | 48pt |
| Title | Color | Default (white/light) |
| High Score | Font Size | 24pt |
| High Score | Color | Gray (0.5, 0.5, 0.5) |
| Button | Width | 200px |
| Button | Height | 50px |
| Button | Font Size | 24pt |
| Button | Alignment | Centered |
| Layout | Anchor | Full screen (15) |
| Layout | Growth | Vertical |

## Data Binding

**High Score Display** → Reads from:
1. `Main.high_score` (loaded from `user://highscore.dat`)
2. Updated whenever `StartScreen` becomes visible
3. Format: "Best: {score}"
